TemplateClass = Template.uploadSection;

function getFileNode(form) {
  return $('input[type="file"]', form)[0];
}

function getFile(form) {
  return getFileNode(form).files[0];
}

TemplateClass.events({
  
  'submit form': function(e, template) {
    e.preventDefault();
    var file = getFile(e.currentTarget);
    if (!file) {
      console.log('Select a file to upload.');
    } else {
      Files.upload(file).then(function(fileObj) {
        console.log('fileObj', fileObj);
      });
    }
  }

});
