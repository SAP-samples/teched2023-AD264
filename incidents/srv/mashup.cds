using { acme.incmgt, IncidentsService } from './incidents-service';
using { s4 } from 's4-bupa-integration/bupa';

// add Customers to Incidents
extend incmgt.Incidents with {
  customer : Association to s4.simple.Customers;
}

// expose Customers and addresses
extend service IncidentsService with {
  @readonly entity Customers as projection on s4.simple.Customers;
  @readonly entity CustomerAddress as projection on s4.simple.CustomerAddress;
}

// Connect Incidents with CustomerAddress. Note the 'on' condition.
extend projection IncidentsService.Incidents  {
  customerAddress: Association to s4.simple.CustomerAddress on customerAddress.bupaID = customer.ID
}

// replica tables
annotate s4.simple.Customers         with @cds.persistence: { table:true, skip:false };
annotate s4.simple.CustomerAddresses with @cds.persistence: { table:true, skip:false };



// --- UI ----

// import basic UI annotations
using from '../app/fiori';

// more UI annotations
annotate IncidentsService.Incidents with @(
  UI: {
    // insert table column
    LineItem : [
      ...up to {Value: title},
      { Value: customer.name, Label: 'Customer' },
      ...
    ],
    // insert customer + address to field group on object page
    FieldGroup #GeneralInformation : {
      Data: [
        { Value: customer_ID, Label: 'Customer'},
        { Label: 'Address', $Type  : 'UI.DataFieldForAnnotation', Target : 'customerAddress/@Communication.Contact' },
        ...
      ]
    }
  }
);

// show customer name + ID
annotate IncidentsService.Incidents:customer with @Common: {
  Text:customer.name,
  TextArrangement: #TextFirst
};
