guardObject = {}

originalPublish = Meteor.publish
Meteor.publish = (name, publishFunction) ->
  originalPublish name, (args...) ->
    publish = @

    disabled = false
    disabled_add = false
    disabled_remove = false
    disabled_change = false

    publish.disableAutoAdd = ->
      disabled_add = true

    publish.disableAutoRemove = ->
      disabled_remove = true

    publish.disableAutoChange = ->
      disabled_change = true

    publish.disableMergebox = ->
      disabled = true

    originalAdded = publish.added
    publish.added = (collectionName, id, fields) ->
      if disabled_add == true
        return

      stringId = @_idFilter.idStringify id

      FiberUtils.synchronize guardObject, "#{collectionName}$#{stringId}", =>
        return originalAdded.call @, collectionName, id, fields unless disabled

        collectionView = @_session.getCollectionView collectionName

        originalSessionDocumentView = collectionView.documents[stringId]

        try
          # Make sure we start with a clean slate for this document ID.
          delete collectionView.documents[stringId]

          originalAdded.call @, collectionName, id, fields
        finally
          if originalSessionDocumentView
            collectionView.documents[stringId] = originalSessionDocumentView
          else
            delete collectionView.documents[stringId]

    originalChanged = publish.changed
    publish.changed = (collectionName, id, fields) ->
      if disabled_change == true
        return

      stringId = @_idFilter.idStringify id

      FiberUtils.synchronize guardObject, "#{collectionName}$#{stringId}", =>
        return originalChanged.call @, collectionName, id, fields unless disabled

        collectionView = @_session.getCollectionView collectionName

        originalSessionDocumentView = collectionView.documents[stringId]

        try
          # Create an empty session document for this id.
          collectionView.documents[id] = new DDPServer._SessionDocumentView()

          # For fields which are being cleared we have to mock some existing
          # value otherwise change will not be send to the client.
          for field, value of fields when value is undefined
            collectionView.documents[id].dataByKey[field] = [subscriptionHandle: @_subscriptionHandle, value: null]

          originalChanged.call @, collectionName, id, fields
        finally
          if originalSessionDocumentView
            collectionView.documents[stringId] = originalSessionDocumentView
          else
            delete collectionView.documents[stringId]

    originalRemoved = publish.removed
    publish.removed = (collectionName, id) ->
      if disabled_remove == true
        return

      stringId = @_idFilter.idStringify id

      FiberUtils.synchronize guardObject, "#{collectionName}$#{stringId}", =>
        return originalRemoved.call @, collectionName, id unless disabled

        collectionView = @_session.getCollectionView collectionName

        originalSessionDocumentView = collectionView.documents[stringId]

        try
          # Create an empty session document for this id.
          collectionView.documents[id] = new DDPServer._SessionDocumentView()

          originalRemoved.call @, collectionName, id
        finally
          if originalSessionDocumentView
            collectionView.documents[stringId] = originalSessionDocumentView
          else
            delete collectionView.documents[stringId]

    publishFunction.apply publish, args
