Meteor.staticPublish = function(topic, callback) {
  Meteor.publish(topic, function() {
    var collectionName, params, publication, query;
    this.disableMergebox();
    publication = this;
    params = arguments;
    query = callback.apply(this, params);
    collectionName = query._cursorDescription.collectionName;
    query.fetch().forEach(function(staticContent) {
      publication.added(collectionName, Random.id(), staticContent);
    });
    publication.ready();
  });
};