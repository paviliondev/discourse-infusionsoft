import { ajax } from 'discourse/lib/ajax';

export default Discourse.Route.extend({
  model() {
    return ajax('/discord/admin');
  },

  setupController(controller, model) {
    controller.set('model', model);
  }
});
