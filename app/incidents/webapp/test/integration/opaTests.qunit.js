sap.ui.require(
    [
        'sap/fe/test/JourneyRunner',
        'incidents/mgt/incidents/test/integration/FirstJourney',
		'incidents/mgt/incidents/test/integration/pages/IncidentsList',
		'incidents/mgt/incidents/test/integration/pages/IncidentsObjectPage',
		'incidents/mgt/incidents/test/integration/pages/ConversationsObjectPage'
    ],
    function(JourneyRunner, opaJourney, IncidentsList, IncidentsObjectPage, ConversationsObjectPage) {
        'use strict';
        var JourneyRunner = new JourneyRunner({
            // start index.html in web folder
            launchUrl: sap.ui.require.toUrl('incidents/mgt/incidents') + '/index.html'
        });

       
        JourneyRunner.run(
            {
                pages: { 
					onTheIncidentsList: IncidentsList,
					onTheIncidentsObjectPage: IncidentsObjectPage,
					onTheConversationsObjectPage: ConversationsObjectPage
                }
            },
            opaJourney.run
        );
    }
);