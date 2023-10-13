using { API_BUSINESS_PARTNER as external } from './API_BUSINESS_PARTNER';

extend service external with {
  event BusinessPartner.Changed @(topic : 'sap.s4.beh.businesspartner.v1.BusinessPartner.Changed.v1') {
    BusinessPartner : external.A_BusinessPartner:BusinessPartner;
  }
  event BusinessPartner.Created @(topic : 'sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1') {
    BusinessPartner : external.A_BusinessPartner:BusinessPartner;
  }
}

// service S4 as projection on external {
//   BusinessPartner.Changed,
//   BusinessPartner.Created,
//   A_SupplierPurchasingOrg { ID }
// }

service S4 {

  event BusinessPartner.Changed : external.BusinessPartner.Changed;
  // event BusinessPartner.Changed : projection on external.BusinessPartner.Changed { BusinessPartner };

  entity Customers         as projection on external.A_BusinessPartner {
    key BusinessPartner           as ID,
        BusinessPartnerFullName   as name,
        to_BusinessPartnerAddress as addresses : redirected to CustomerAddresses
  };

  entity CustomerAddresses as projection on external.A_BusinessPartnerAddress {
    key AddressID       as ID,
        BusinessPartner as bupaID,
        CityName        as city,
        StreetName      as street,
        Country         as country,
        PostalCode      as postalCode,
        Region          as region
  };

  // view that helps reduce n addresses per customer to 1
  entity CustomerAddress   as projection on CustomerAddresses group by bupaID order by
    bupaID;

}


// --- UI annotations - could also go into a separate file
annotate S4.Customers with @UI.Identification : [{Value : name}];
annotate S4.Customers with @cds.odata.valuelist;

annotate S4.Customers with {
  ID   @title : 'Customer ID';
  name @title : 'Customer Name';
}

annotate S4.CustomerAddress with @(Communication.Contact : {
  kind : #location,
  fn   : city,
  adr  : [{
    $Type    : 'Communication.AddressType',
    type     : #preferred,
    locality : city,
    code     : postalCode,
    street   : street,
    region   : region,
    country  : country,
  }],
});
