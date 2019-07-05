import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { default as computed } from 'ember-addons/ember-computed-decorators';

export default Ember.Controller.extend({
  notAuthorized: Ember.computed.not('model.authorized'),

  @computed('group', 'job')
  syncEnabled(group, job) {
    return group && job;
  },

  actions: {
    authorize() {
      const discordUrl = "https://discordapp.com/api/oauth2/authorize";
      const clientId = Discourse.SiteSettings.discord_client_id;
      window.location.href = discordUrl + `?client_id=${clientId}&scope=bot&permissions=268435456`;
    },

    startJob() {
      this.set('startingJob', true);

      const group = this.get('group');
      const role = this.get('role');

      ajax('/discord/job/start', {
        type: 'PUT',
        data: {
          group,
          role
        }
      }).catch(popupAjaxError)
        .then(result => {
          if (result && result.success) {
            this.set('jobStarted', true);
          }
        }).finally(() => this.set('startingJob', false));
    }
  }
});
