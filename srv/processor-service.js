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


    // <<< And not below here

    return super.init()
  }
}

module.exports = ProcessorService
