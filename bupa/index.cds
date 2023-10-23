using {API_BUSINESS_PARTNER as S4} from './API_BUSINESS_PARTNER';

// event definition
extend service S4 {
  // https://api.sap.com/event/CE_BUSINESSPARTNEREVENTS/resource
  event BusinessPartner.Changed @(topic : 'sap.s4.beh.businesspartner.v1.BusinessPartner.Changed.v1') {
    BusinessPartner : S4.A_BusinessPartner:BusinessPartner;
  }
}
