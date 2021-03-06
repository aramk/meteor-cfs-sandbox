env = process.env
REMOVE_TMP_ON_LOAD = true

# Removes the temporary directory on startup.
if REMOVE_TMP_ON_LOAD
  console.log('Removing TEMP_DIR...')
  TEMP_DIR = env.TEMP_DIR
  if TEMP_DIR
    console.log('TEMP_DIR=', TEMP_DIR)
    shell = Meteor.npmRequire('shelljs')
    path = Meteor.npmRequire('path')
    shell.rm('-rf', path.join(TEMP_DIR, '*'))
    console.log('Removed TEMP_DIR')
  else
    console.log('No TEMP_DIR set')

adapter = 'FILESYSTEM'
Adapters =
  FILESYSTEM:
    config: {}
  S3:
    config: {}

# Filesystem adapter
FILES_DIR = env.FILES_DIR
if FILES_DIR?
  Adapters.FILESYSTEM.config.path = FILES_DIR + '/cfs'

# S3 adapter
s3BucketName = env.S3_BUCKET_NAME
if s3BucketName
  adapter = 'S3'
  Adapters.S3.config.bucket = s3BucketName
  s3Region = env.S3_REGION
  Adapters.S3.config.region = s3Region if s3Region

cfsAdapter = env.CFS_ADAPTER
if cfsAdapter
  adapter = cfsAdapter

adapterArgs = Adapters[adapter]
console.log('Using cfs adapter:', adapter)
if adapter == 'FILESYSTEM'
  console.log('Using cfs directory:', (adapterArgs.config.path ? 'default path'))

@FileUtils =

  getReadStream: (fileId) ->
    item = Files.findOne(fileId)
    unless item
      throw new Meteor.Error(404, 'File with ID ' + fileId + ' not found.')
    item.createReadStream('files')

  getBuffer: (fileId) ->
    reader = @getReadStream(fileId)
    Buffers.fromStream(reader)

Meteor.methods

  'files/download/string': (id) -> FileUtils.getBuffer(id).toString()
  'files/download/json': (id) ->
    data = FileUtils.getBuffer(id).toString()
    if data == ''
      throw new Meteor.Error(400, 'Attempted to download empty JSON')
    else
      JSON.parse(data)
  'files/adapter': ->
    {adapter: adapter, args: Adapters[adapter]}

