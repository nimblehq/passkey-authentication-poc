import { Controller } from "stimulus"
import * as Credential from "credential";

import { showMessage } from "../messenger";

export default class extends Controller {

  create(event) {
    var [data, status, xhr] = event.detail;
    var credentialOptions = data;

    // Registration
    if (credentialOptions["user"]) {
      var credential_label = event.target.querySelector("input[name='registration[label]']").value;
      var callback_url = `registrations/callback?credential_label=${credential_label}`

      Credential.create(encodeURI(callback_url), credentialOptions);
    }
  }

  error(event) {
    let response = event.detail[0];
    showMessage(response["errors"][0])
  }
}
