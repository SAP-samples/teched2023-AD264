const cds = require('@sap/cds')

class ProcessorService extends cds.ApplicationService {
  /** Registering custom event handlers */
  async init() {

    this.before('UPDATE', 'Incidents', (req) => this.onUpdate(req));
    this.before('CREATE', 'Incidents', (req) => this.changeUrgencyDueToSubject(req.data));

    // Delegate Value Help reads for Customers to S4 backend
    const S4bupa = await cds.connect.to('API_BUSINESS_PARTNER')
    this.on('READ', ['Customers', 'CustomerAddresses'], async (req) => {
      console.log(`>> delegating '${req.target.name}' to S4 service...`, req.query)
      const result = await S4bupa.run(req.query)
      return result
    })

    const db = await cds.connect.to('db')     // our primary database
    const { Customers, CustomerAddresses }  = db.entities('s4.simple')  // CDS definition of the entities

    this.after (['CREATE','UPDATE'], 'Incidents', async (data) => {
      const { customer_ID: ID } = data
      if (ID) {
        let replicated = await db.exists (Customers,ID)
        if (!replicated) { // initially replicate Customers info
          let customer = await S4bupa.read (Customers,ID)
          console.log ('>> Updating customer', ID, customer)
          await INSERT(customer) .into (Customers)

          // fetch the addresses
          // TODO eliminate this by adding it as an `expand` clause to the query above
          let customerAddresses = await S4bupa.run (SELECT.from(CustomerAddresses).where({bupaID: ID}))
          if (customerAddresses.length) {
            console.log ('>> Updating customer addresses', customerAddresses)
            try {
              await INSERT(customerAddresses) .into (CustomerAddresses)
            } catch (err) {/*ignore */ }
          }
        }
      }
    })

      // update cache if BusinessPartner has changed
    S4bupa.on('BusinessPartner.Changed', async ({ event, data }) => {
      console.log('<< received', event, data)
      const { BusinessPartner: ID } = data
      const customer = await S4bupa.read (Customers, ID)
      let exists = await db.exists (Customers,ID)
      if (exists)
        await UPDATE (Customers, ID) .with (customer)
      else
        await INSERT.into (Customers) .entries (customer)
    })

    return super.init();
  }

  changeUrgencyDueToSubject(data) {
    if (data) {
      const incidents = Array.isArray(data) ? data : [data];
      incidents.forEach((incident) => {
        if (incident.title?.toLowerCase().includes('urgent')) {
          incident.urgency = { code: 'H', descr: 'High' };
        }
      });
    }
  }

  /** Custom Validation */
  async onUpdate (req) {
    const { status_code } = await SELECT.one(req.subject, i => i.status_code).where({ID: req.data.ID})
    if (status_code === 'C')
      return req.reject(`Can't modify a closed incident`)
  }
}

module.exports = ProcessorService