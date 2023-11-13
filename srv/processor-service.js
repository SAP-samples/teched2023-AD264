const cds = require('@sap/cds')

class ProcessorService extends cds.ApplicationService {
  async init() {

    this.before('CREATE', 'Incidents', ({data}) => {
      if (data) {
        const incidents = Array.isArray(data) ? data : [data]
        incidents.forEach(incident => {
          if (incident.title?.toLowerCase().includes('urgent')) {
            incident.urgency = { code: 'H' }
          }
        })
      }
    })

    // >>> Code goes after here

    // connect to S4 backend
    const S4bupa = await cds.connect.to('API_BUSINESS_PARTNER')
    // delegate reads for Customers to remote service
    this.on('READ', 'Customers', async (req) => {
      console.log(`>> delegating '${req.target.name}' to S4 service...`, req.query)
      const result = await S4bupa.run(req.query)
      return result
    })

    const db = await cds.connect.to('db')                // our primary database
    const { Customers }  = db.entities('incidents.mgt')  // CDS definition of the Customers entity

    this.after (['CREATE','UPDATE'], 'Incidents', async (data) => {
      const { customer_ID: ID } = data
      if (ID) {
        console.log ('>> Updating customer', ID)
        const customer = await S4bupa.read (Customers,ID) // read from remote
        await UPSERT(customer) .into (Customers)          // update cache
      }
    })

    // update cache if BusinessPartner has changed
    S4bupa.on('BusinessPartner.Changed', async ({ event, data }) => {
      console.log('<< received', event, data)
      const { BusinessPartner: ID } = data
      const customer = await S4bupa.read (Customers, ID)
      await UPSERT.into (Customers) .entries (customer)
    })


    // <<< And not below here

    return super.init()
  }
}

module.exports = ProcessorService
