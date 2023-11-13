const cds = require('@sap/cds')

describe('Test ProcessorService', () => {
  const { GET, POST, expect } = cds.test(__dirname + '/..')

  it('Should create urgent incidents', async () => {
    // create draft incident
    let draftId
    {
      const { statusText, data } = await POST(`/odata/v4/processor/Incidents`, {
        title: 'Urgent attention required !',
        status_code: 'N'
      })
      expect(statusText).to.equal('Created')
      draftId = data.ID
    }

    // activate draft
    {
      const { data } = await POST(
        `/odata/v4/processor/Incidents(ID=${draftId},IsActiveEntity=false)/ProcessorService.draftActivate`
      )
      expect(data.urgency_code).to.eql('H')
    }
  })

  it('Should have incidents', async () => {
    const { Incidents } = cds.entities('ProcessorService')
    expect((await SELECT.from(Incidents)).length).to.be.gte(4)
  })

  it('Should have incidents - HTTP', async () => {
    const { data } = await GET`/odata/v4/processor/Incidents`
    expect(data.value.length).to.be.gte(4)
  })

})
