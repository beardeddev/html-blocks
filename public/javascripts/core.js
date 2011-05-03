// Copyright Vitaliy Litvinenko aka beardeddev

function addUploadField(name, selector){
	$('<li><input name="' + name + '[]" type="file"></li>').appendTo(selector)
} 
