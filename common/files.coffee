@Files = new FS.Collection 'files', stores: [
  new FS.Store.FileSystem('files', {})
]

Files.upload = (obj) ->
  console.debug('Uploading file', obj)
  df = Q.defer()
  Files.insert obj, (err, fileObj) ->
    if err
      df.reject(err)
      return
    # TODO(aramk) Remove timeout and use an event callback.
    timerHandler = Meteor.bindEnvironment ->
      progress = fileObj.uploadProgress()
      uploaded = fileObj.isUploaded()
      if uploaded
        clearTimeout(handle)
        df.resolve(fileObj)
    handle = setInterval timerHandler, 1000
  df.promise

Files.allow
  download: Collections.allow
  insert: Collections.allow
  update: Collections.allow
  remove: Collections.allow
