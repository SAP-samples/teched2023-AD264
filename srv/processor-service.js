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




    // <<< And not below here

    return super.init()
  }
}

module.exports = ProcessorService
