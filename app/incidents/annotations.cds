using { ProcessorService as service, incidents } from '../../srv/processor-service';

// enable drafts for editing in the UI
annotate service.Incidents with @odata.draft.enabled;

// table columns in the list
annotate service.Incidents with @(
    UI.LineItem : [
        {
            $Type : 'UI.DataField',
            Value : title,
            Label : '{i18n>Title}',
        },
        {
            $Type : 'UI.DataField',
            Value : status.name,
            Criticality : status.criticality,
            Label : '{i18n>Status}',
        },
        {
            $Type : 'UI.DataField',
            Value : urgency.descr,
            Criticality : urgency.criticality,
            Label : '{i18n>Urgency}',
        },
    ]
);
annotate service.Incidents with @(
    UI.FieldGroup #GeneralInformation : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : title,
                Label : '{i18n>Title}',
            }
        ],
    },
    UI.Facets : [
        {
            $Type : 'UI.CollectionFacet',
            Label : '{i18n>Overview}',
            ID : 'i18nOverview',
            Facets : [
                {
            $Type : 'UI.ReferenceFacet',
            ID : 'GeneratedFacet1',
            Label : '{i18n>generalInformation}',
            Target : '@UI.FieldGroup#GeneralInformation',
        },
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : '{i18n>Details}',
                    ID : 'i18nDetails',
                    Target : '@UI.FieldGroup#i18nDetails',
                },],
        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : '{i18n>Conversations}',
            ID : 'i18nConversations',
            Target : 'conversations/@UI.LineItem#i18nConversations',
        },
    ]
);
annotate service.Incidents with @(
    UI.SelectionFields : [
        urgency_code,
        status_code,
    ]
);
annotate service.Incidents with {
    status @Common.Label : '{i18n>Status}'
};
annotate service.Incidents with {
    urgency @Common.Label : '{i18n>Urgency}'
};
annotate service.Incidents with {
    status @Common.ValueListWithFixedValues : true
};
annotate service.Incidents with {
    urgency @Common.ValueListWithFixedValues : true
};
annotate service.Incidents with @(
    UI.HeaderInfo : {
        Title : {
            $Type : 'UI.DataField',
            Value : title,
        },
        TypeName : '',
        TypeNamePlural : '',
        TypeImageUrl : 'sap-icon://alert',
    }
);
annotate service.Incidents with @(
    UI.FieldGroup #i18nDetails : {
        $Type : 'UI.FieldGroupType',
        Data : [
            {
                $Type : 'UI.DataField',
                Value : status_code,
                Criticality : status.criticality,
            },
            {
                $Type : 'UI.DataField',
                Value : urgency_code,
            },],
    }
);
annotate service.Status with {
    code @Common.Text : name
};
annotate service.Urgency with {
    code @Common.Text : name
};
annotate service.Incidents with {
    status  @Common.Text : status.name;
    urgency @Common.Text : urgency.name;
};

annotate service.Conversations with @(
    UI.LineItem #i18nConversations : [
        {
            $Type : 'UI.DataField',
            Value : author,
            Label : '{i18n>Author}',
        },{
            $Type : 'UI.DataField',
            Value : timestamp,
            Label : '{i18n>ConversationDate}',
        },{
            $Type : 'UI.DataField',
            Value : message,
            Label : '{i18n>Message}',
        },]
);

annotate service.Customers with @UI.Identification : [{ Value:name }];
annotate service.Customers with @cds.odata.valuelist;
annotate service.Customers with {
  ID   @title : 'Customer ID';
  name @title : 'Customer Name';
};

annotate service.Incidents with @(
  UI: {
    // insert table column
    LineItem : [
      ...up to { Value: title },
      { Value: customer.name, Label: 'Customer' },
      ...
    ],

    // insert customer to field group
    FieldGroup #GeneralInformation : {
      Data: [
        ...,
        { Value: customer_ID, Label: 'Customer'}
      ]
    },
  }
);

// for an incident's customer, show both name and ID
annotate service.Incidents:customer with @Common: {
  Text: customer.name,
  TextArrangement: #TextFirst
};
