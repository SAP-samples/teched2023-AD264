using { API_BUSINESS_PARTNER as S4 } from './API_BUSINESS_PARTNER';

// event definitions see https://api.sap.com/event/CE_BUSINESSPARTNEREVENTS/resource

extend service S4 {
  event BusinessPartner.Created @(topic : 'sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1') {
    BusinessPartner : S4.A_BusinessPartner:BusinessPartner;
  }
  event BusinessPartner.Changed @(topic : 'sap.s4.beh.businesspartner.v1.BusinessPartner.Changed.v1') {
    BusinessPartner : S4.A_BusinessPartner:BusinessPartner;
  }
}
