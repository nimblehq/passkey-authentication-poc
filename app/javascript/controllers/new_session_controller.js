import { Controller } from "stimulus"
import * as Credential from "credential";

import { showMessage } from "../messenger";

export default class extends Controller {

  create(event) {
    var [data, status, xhr] = event.detail;
    var credentialOptions = data;

    Credential.get(credentialOptions);
  }

  error(event) {
    let response = event.detail[0];
    showMessage(response["errors"][0])
  }
}
