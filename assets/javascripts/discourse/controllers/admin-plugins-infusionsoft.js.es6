import { ajax } from 'discourse/lib/ajax';
import { popupAjaxError } from 'discourse/lib/ajax-error';
import { eventKeys } from '../lib/utilities';

export default Ember.Controller.extend({
  loadingSubscriptions: false,
  eventKeys: eventKeys,
  eventKey: eventKeys[0].id,
  notAuthorized: Ember.computed.not('model.authorized'),
  
  getUrl() {
    if (location.hostname === 'localhost') {
      return 'https://45c8ad98.ngrok.io';
    } else {
      return location.protocol+'//'+location.hostname+(location.port ? ':'+location.port: '');
    }
  },

  actions: {
    authorize() {
      let infusionsoftUrl = "https://signin.infusionsoft.com/app/oauth/authorize";
      let discourseUrl = this.getUrl();
      let clientId = Discourse.SiteSettings.infusionsoft_client_id;
      let redirectUri = encodeURIComponent(discourseUrl + "/infusionsoft/authorization/callback");
      let params = `?client_id=${clientId}&redirect_uri=${redirectUri}&response_type=code`;

      window.location.href = infusionsoftUrl + params;
    },

    createSubscription(params) {
      this.set('loadingSubscriptions', true)

      const eventKey = this.get('eventKey');

      ajax('/infusionsoft/subscription', {
        type: 'POST',
        data: {
          event: eventKey
        }
      }).catch(popupAjaxError)
        .then(result => {
          if (result.success) {
            this.set('model.subscriptions', result.subscriptions);
          }
        }).finally(() => this.set('loadingSubscriptions', false));
    },

    removeSubscription(params) {
      this.set('loadingSubscriptions', true)

      ajax('/infusionsoft/subscription', {
        type: 'DELETE',
        data: {
          event: params['event'],
          key: params['key']
        }
      }).catch(popupAjaxError)
        .then(result => {
          if (result.success) {
            this.set('model.subscriptions', result.subscriptions);
          }
        }).finally(() => this.set('loadingSubscriptions', false));
    },

    verifySubscription(params) {
      this.set('loadingSubscriptions', true)

      ajax('/infusionsoft/subscription/verify', {
        type: 'PUT',
        data: {
          event: params['event'],
          key: params['key']
        }
      }).catch(popupAjaxError)
        .then(result => {
          if (result.success) {
            this.set('model.subscriptions', result.subscriptions);
          }
        }).finally(() => this.set('loadingSubscriptions', false));
    },

    syncTagGroups() {
      this.set('startingJob', true);

      ajax('/infusionsoft/job/start', {
        type: 'PUT',
        data: {
          job: 'tag_group_sync'
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
