import { registerUnbound } from 'discourse-common/lib/helpers';
import { eventKeys } from '../lib/utilities';

registerUnbound('infusionsoft-event-label', function(eventKey) {
  const key = eventKeys.find(k => k.id == eventKey);
  return new Handlebars.SafeString(key ? key.name : eventKey);
});
