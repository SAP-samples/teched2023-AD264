namespace incidents.mgt;

using
{
    cuid,
    managed,
    sap.common.CodeList
}
from '@sap/cds/common';

/**
 * Incidents created by Customers.
 */
entity Incidents : cuid, managed {
  title         : String                                   @title : '{i18n>Title}';
  urgency       : Association to Urgency  default 'Medium' @title : '{i18n>Urgency}';
  status        : Association to Status   default 'New'    @title : '{i18n>Status}';
  conversations : Composition of many Conversations  on conversations.incidents = $self;
}

entity Status : CodeList {
  key code        : String enum {
        new        = 'N';
        assigned   = 'A';
        in_process = 'I';
        on_hold    = 'H';
        resolved   = 'R';
        closed     = 'C';
      };
      criticality : Integer;
}

entity Urgency : CodeList {
  key code : String enum {
        high   = 'H';
        medium = 'M';
        low    = 'L';
      };
      criticality : Integer;
}

entity Conversations : cuid, managed {
  incidents : Association to Incidents;
  timestamp : DateTime @cds.on.insert: $now   @title: 'Time';
  author    : String   @cds.on.insert: $user  @title: 'Author' ;
  message   : String                          @title: 'Message';
}
