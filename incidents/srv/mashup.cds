using { acme.incmgt, ProcessorService } from './processor-service';
using { s4 } from 's4-bupa-integration/bupa';

// add Customers to Incidents
extend incmgt.Incidents with {
  customer : Association to s4.simple.Customers;
}

// expose Customers and addresses
extend service ProcessorService with {
  @readonly entity Customers as projection on s4.simple.Customers;
  @readonly entity CustomerAddress as projection on s4.simple.CustomerAddress;
}

// Connect Incidents with CustomerAddress. Note the 'on' condition.
extend projection ProcessorService.Incidents  {
  customerAddress: Association to s4.simple.CustomerAddress on customerAddress.bupaID = customer.ID
}

// replica tables
annotate s4.simple.Customers         with @cds.persistence: { table:true, skip:false };
annotate s4.simple.CustomerAddresses with @cds.persistence: { table:true, skip:false };



// --- UI ----

// import basic UI annotations
using from '../app/fiori';

// more UI annotations
annotate ProcessorService.Incidents with @(
  UI: {
    // insert table column
    LineItem : [
      ...up to { Value: title },
      { Value: customer.name, Label: '{i18n>Customer}' },
      ...
    ],
    // insert customer + address to field group on object page
    FieldGroup #GeneratedGroup1 : {
      Data: [
        { Value: customer_ID, Label: '{i18n>Customer}'},
        { Label: 'Address', $Type  : 'UI.DataFieldForAnnotation', Target : 'customerAddress/@Communication.Contact' },
        ...
      ]
    }
  }
);

// show customer name + ID
annotate ProcessorService.Incidents:customer with @Common: {
  Text:customer.name,
  TextArrangement: #TextFirst
};

annotate ProcessorService.Incidents with {
  customer @(Common.ValueList : {
    $Type : 'Common.ValueListType',
    CollectionPath : 'Customers',
    Parameters : [
      {
        $Type : 'Common.ValueListParameterInOut',
        LocalDataProperty : customer_ID,
        ValueListProperty : 'ID',
      },
      {
        $Type : 'Common.ValueListParameterDisplayOnly',
        ValueListProperty : 'name',
      }
    ],
  },
  Common.ValueListWithFixedValues : false
)};
