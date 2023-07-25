import { Controller } from "stimulus"
import * as Credential from "credential";

export default class extends Controller {
  create(event) {
    var [data, status, xhr] = event.detail;
    var credentialOptions = data;
    var credential_label = event.target.querySelector("input[name='credential[label]']").value;
    var callback_url = `users/credentials/callback?credential_label=${credential_label}`

    Credential.create(encodeURI(callback_url), credentialOptions);
  }
}
