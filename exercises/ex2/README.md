# Exercise 2 - Service Integration

In this exercise, you will add `Customers` to `Incidents` to specify who created an incident.

Customer data is available in _SAP S/4HANA Cloud_ as part of the _Business Partners_ Service.  You will connect to this service from the _Incidents Management_ application.

You don't need to implement this integration from scratch, but you can use a integration package that another team has built.


## Checkout Base Version of the Application

## Add Integration Package

👉 In the terminal, run:

```sh
npm add git+https://github.com/SAP-samples/teched2023-AD264#bupa-integration-package
```

The package was added as a `git` dependency in `package.json`.

Let's see what got installed by expanding the folder `node_modules/s4-bupa-integration` (in the file explorer or in the terminal):

```
node_modules/s4-bupa-integration
├── bupa
│   ├── API_BUSINESS_PARTNER.csn
│   ├── API_BUSINESS_PARTNER.edmx
│   ├── API_BUSINESS_PARTNER.js
│   ├── data
│   │   └── API_BUSINESS_PARTNER-A_BusinessPartner.csv
│   └── index.cds
└── package.json
```

👉 While you're at installing dependencies, add this in addition:

```sh
npm add @sap-cloud-sdk/http-client  # SAP Cloud SDK for HTTP connectivity, resilience, destination management
```

> CAP applications use the [SAP Cloud SDK](https://sap.github.io/cloud-sdk/) for HTTP connectivity.  SAP Cloud SDK abstracts authentication flows and communication with SAP BTPs [connectivity, destination, and authentication](https://sap.github.io/cloud-sdk/docs/js/features/connectivity/destination).
It doesn't matter whether you want to connect against cloud or on-premises systems.



👉 In file `db/data-model` add this line at the top:

```cds
using { API_BUSINESS_PARTNER as S4 } from 's4-bupa-integration/bupa';
```

👉 Register it in the application configuration.  Add this top-level to `package.json` (pay attention to syntax errors):
```jsonc
  "cds": {
    "requires": {
      "API_BUSINESS_PARTNER": {
        "kind": "odata-v2",
        "model": "s4-bupa-integration/bupa"
      }
    }
  }
```


## Service Adaptation

For the first version of the application, you need only two fields from the `A_BusinessPartner` entity. To do this, you create a [_projection_](https://cap.cloud.sap/docs/guides/using-services#model-projections) on the external service. Since in this example, you are interested in business partners in a role as customer, you use the name `Customers` for your projection.

👉 Add `Customers`:
- Create a `Customers` entity as a projection to the `A_BusinessPartner` entity that you have just imported. It shall have two fields
  - `ID` for the remote `BusinessPartner`
  - `name` for the remote `BusinessPartnerFullName`
- Add an association to `Incidents` pointing to (one) `Customer`
- Expose the `Customers` entity similar to `Incidents`

<details>
<summary>This is how it's done:</summary>

Add this to `db/data-model.cds`:

```cds
entity Customers   as projection on S4.A_BusinessPartner {
  key BusinessPartner         as ID,
      BusinessPartnerFullName as name
}
```

Then add:

```cds
entity Incidents {
  ...
  customer      : Association to Customers;
}
```

In `srv/processor-service.cds`, add this line:

```cds
service ... {
  ...
  entity Customers as projection on mgt.Customers;
}
```

</details>


## Delegate calls to remote system

To make the value help for `Customers` work, we need to redirect the request to the remote system (or our mock).
Otherwise, the framework would read it from a local DB table, which does not exist.

So, create a file `srv/processor-service.js` with this content:

```js
const cds = require('@sap/cds')

class ProcessorService extends cds.ApplicationService {
  /** Registering custom event handlers */
  async init() {

    // Delegate Value Help reads for Customers to S4 backend
    const S4bupa = await cds.connect.to('API_BUSINESS_PARTNER')
    this.on('READ', 'Customers', async (req) => {
      console.log(`>> delegating '${req.target.name}' to S4 service...`, req.query)
      const result = await S4bupa.run(req.query)
      return result
    })
  }
}

module.exports = ProcessorService
```


## Run and Inspect the Application

```sh
cds watch
```


```sh
[cds] - mocking API_BUSINESS_PARTNER {
  path: '/odata/v4/api-business-partner',
  impl: 'node_modules/s4-bupa-integration/bupa/API_BUSINESS_PARTNER.js'
}
```

## Test with Remote System

As a ready-to-use remote service, we use the sandbox system of _SAP Business Accelerator Hub_.

> To use your own SAP S/4HANA Cloud system, see this [tutorial](https://developers.sap.com/tutorials/btp-app-ext-service-s4hc-use.html). You don't need it for this tutorial though.

1. Create a **new file `.env`** in the `incidents` folder and add **environment variables** that hold the URL of the sandbox as well as a personal API Key:

    ```properties
    DEBUG=remote
    cds.requires.API_BUSINESS_PARTNER.[sandbox].credentials.url=https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER/
    cds.requires.API_BUSINESS_PARTNER.[sandbox].credentials.headers.APIKey=<Copied API Key>
    ```

    Note the `[sandbox]` segment which denotes a [configuration profile](https://cap.cloud.sap/docs/node.js/cds-env#profiles) named `sandbox`.  The name has no special meaning.  You will see below how to use it.

2. Get an **API key**:

    - Go to [SAP Business Accelerator Hub](https://api.sap.com).
    - On the top right corner, expand the _Hi ..._ dropdown.  Choose _Settings_.
    - Click on _Show API Key_. Choose _Copy Key and Close_.

      ![Get API key from SAP API Business Hub](./assets/hub-api-key.png)

3. **Add the key** to the `.env` file

    > By putting the key in a separate file, you can exclude it from the Git repository (see the `.gitignore` file).<br>
    >
    > Also note how the `cds.requires.API_BUSINESS_PARTNER` structure in the `.env file` matches to the `package.json` configuration.<br>
    To learn about more configuration options for CAP Node.js applications, see the [documentation](https://cap.cloud.sap/docs/node.js/cds-env).

Now kill the server with <kbd>Ctrl+C</kbd> and run again with the `sandbox` profile activated:

```sh
cds watch --profile sandbox
```

In the server log, you can see that the configuration is effective:

```sh
...
[cds] - connect to API_BUSINESS_PARTNER > odata-v2 {
  url: 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/API_BUSINESS_PARTNER/',
  headers: { APIKey: '...' }
}
...
```

On the application's index page, the **mocked service is gone**, because it is no longer served in the application. Instead, it is assumed to be **running in a remote system**.  Through the configuration above, the system knows how to connect to it.

Open `/odata/v4/processor/Customers` to see the data coming from the remote system.

> If you get a `401` error instead, check your API key in the `.env` file.  After a change in the configuration, kill the server with <kbd>Ctrl+C</kbd> and start it again.

You can also see something like this in the log (due to the `DEBUG=remote` variable from the `.env` file above):

```
[remote] - GET https://.../API_BUSINESS_PARTNER/A_BusinessPartner
  ?$select=BusinessPartner,BusinessPartnerFullName&$inlinecount=allpages&$top=74&$orderby=BusinessPartner%20asc
...
```

This is the remote request sent by the framework when `S4bupa.run(req.query)` is executed.  The **`req.query` object is transparently translated to an OData query** `$select=BusinessPartner,BusinessPartnerFullName&$top=...&$orderby=...`.  The entire HTTP request (completed by the sandbox URL configuration) is then sent to the remote system with the help of **SAP Cloud SDK**.

Note how **simple** the execution of remote queries is.  No manual OData query construction needed, no HTTP client configuration like authentication, no response parsing, error handling, nor issues with hard-wired host names etc.

> See the [documentation on CQN](https://pages.github.tools.sap/cap/docs/cds/cqn) for more on such queries in general.  The [service consumption guide](https://pages.github.tools.sap/cap/docs/guides/using-services#execute-queries) details out how they are translated to remote requests.