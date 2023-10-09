using {API_BUSINESS_PARTNER as S4} from './API_BUSINESS_PARTNER';

namespace s4.simple; // meaning these are simplified S4 definitions

// event definition
extend service S4 {
  // https://api.sap.com/event/CE_BUSINESSPARTNEREVENTS/resource
  event BusinessPartner.Changed @(topic : 'sap.s4.beh.businesspartner.v1.BusinessPartner.Changed.v1') {
    BusinessPartner : S4.A_BusinessPartner:BusinessPartner;
  }
}

entity Customers         as projection on S4.A_BusinessPartner {
  key BusinessPartner           as ID,
      BusinessPartnerFullName   as name,
      to_BusinessPartnerAddress as addresses : redirected to CustomerAddresses
};

entity CustomerAddresses as projection on S4.A_BusinessPartnerAddress {
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


// --- UI annotations - could also go into a separate file
annotate Customers with @UI.Identification : [{Value : name}];
annotate Customers with @cds.odata.valuelist;

annotate Customers with {
  ID   @title : 'Customer ID';
  name @title : 'Customer Name';
}

annotate CustomerAddress with @(Communication.Contact : {
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
