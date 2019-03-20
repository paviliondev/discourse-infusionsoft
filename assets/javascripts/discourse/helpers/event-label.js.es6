import { registerUnbound } from 'discourse-common/lib/helpers';
import { eventKeys } from '../lib/utilities';

registerUnbound('event-label', function(eventKey) {
  return new Handlebars.SafeString(eventKeys.find(k => k.id == eventKey).name);
});
