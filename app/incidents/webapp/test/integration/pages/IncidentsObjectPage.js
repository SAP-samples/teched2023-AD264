sap.ui.define(['sap/fe/test/ObjectPage'], function(ObjectPage) {
    'use strict';

    var CustomPageDefinitions = {
        actions: {},
        assertions: {}
    };

    return new ObjectPage(
        {
            appId: 'incidents.mgt.incidents',
            componentId: 'IncidentsObjectPage',
            contextPath: '/Incidents'
        },
        CustomPageDefinitions
    );
});