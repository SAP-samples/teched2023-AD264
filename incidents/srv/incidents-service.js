module.exports = (async function() {

  const cds = require('@sap/cds');
  const S4bupa = await cds.connect.to('API_BUSINESS_PARTNER')

  // Delegate Value Help reads for Customers to S4 backend
  this.on('READ', ['Customers', 'CustomerAddresses'], (req) => {
    console.log(`>> delegating '${req.target.name}' to S4 service...`, req.query)
    return S4bupa.run(req.query)
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


})