'use string';

const applicationServerKey = window.vapidPublicKey;

let pushButton;
let isSubscribed = false;
let swRegistration = null;

if ('serviceWorker' in navigator && 'PushManager' in window) {
  console.log('Service Worker and Push is supported');

  // navigator.serviceWorker.register('/serviceworker.js', { scope: './' })

  navigator.serviceWorker.register('/serviceworker.js')
    .then(function(swReg) {
      console.log('[Companion]', 'Service worker registered!', swReg);

      swRegistration = swReg;

      pushButton = document.querySelector('.js-push-btn');
      initialiseUI();
    })
    .catch(function(error) {
      console.error('Service Worker Error', error);
    });
} else {
  console.warn('Push messaging is not supported');
  pushButton.textContent = 'Push Not Supported';
}

function initialiseUI() {
  if(!pushButton) {
    console.log('no push button exist.')
    return;
  }

  pushButton.addEventListener('click', function() {
    pushButton.disabled = true;
    if (isSubscribed) {
      unsubscribeUser();
    } else {
      subscribeUser();
    }
  });

  // Set the initial subscription value
  swRegistration.pushManager.getSubscription()
  .then(function(subscription) {
    isSubscribed = !(subscription === null);

    if (isSubscribed) {
      console.log('User IS subscribed.');
    } else {
      console.log('User is NOT subscribed.');
    }

    updateBtn();
  });
}

function subscribeUser() {
  // const applicationServerKey = urlB64ToUint8Array(applicationServerPublicKey);
  swRegistration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: applicationServerKey
  })
  .then(function(subscription) {
    console.log('User is subscribed:', subscription);

    updateSubscriptionOnServer(subscription);

    isSubscribed = true;

    updateBtn();
  })
  .catch(function(err) {
    console.log('Failed to subscribe the user: ', err);
    updateBtn();
  });
}

function unsubscribeUser() {
  swRegistration.pushManager.getSubscription()
  .then(function(subscription) {
    if (subscription) {
      return subscription.unsubscribe();
    }
  })
  .catch(function(error) {
    console.log('Error unsubscribing', error);
  })
  .then(function() {
    updateSubscriptionOnServer(null);

    console.log('User is unsubscribed.');
    isSubscribed = false;

    updateBtn();
  });
}

function updateBtn() {
  if (Notification.permission === 'denied') {
    pushButton.textContent = 'プッシュ通知をブロックしています';
    pushButton.disabled = true;
    // updateSubscriptionOnServer(null);
    return;
  }

  if (isSubscribed) {
    pushButton.textContent = 'プッシュ通知を無効にする';
  } else {
    pushButton.textContent = 'プッシュ通知を有効にする';
  }

  pushButton.disabled = false;
}

function updateSubscriptionOnServer(subscription) {
  console.log(subscription);
  var params = {
    subscription: subscription.toJSON()
  }

  console.log(params);

  // TODO サーバサイドに subscription 情報を POST 処理

  const subscriptionJson = document.querySelector('.js-subscription-json');
  const subscriptionDetails =
    document.querySelector('.js-subscription-details');

  if (subscription) {
    subscriptionJson.textContent = JSON.stringify(subscription);
    subscriptionDetails.classList.remove('is-invisible');
  } else {
    subscriptionDetails.classList.add('is-invisible');
  }
}
