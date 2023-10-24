module.exports = function () {
  const { A_BusinessPartner } = this.entities;

  this.after('UPDATE', A_BusinessPartner, async data => {
    const event = { BusinessPartner: data.BusinessPartner }
    console.log('>> BusinessPartner.Changed', event)
    await this.emit('BusinessPartner.Changed', event);
  })

  this.after('CREATE', A_BusinessPartner, async data => {
    const event = { BusinessPartner: data.BusinessPartner }
    console.log('>> BusinessPartner.Created', event)
    await this.emit('BusinessPartner.Created', event);
  })
}