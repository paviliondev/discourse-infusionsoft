import { ajax } from 'discourse/lib/ajax';

export default Discourse.Route.extend({
  model() {
    return ajax('/infusionsoft/admin');
  },

  setupController(controller, model) {
    console.log(model)
    controller.set('model', model);
  }
});
