// Script to "UNBLOCK" all files in the current directory by pete.at.redtitan.com

// (c) RedTitan Technology 2007

// http://www.pclviewer.com

var shell=new ActiveXObject("WScript.Shell");

fso=new ActiveXObject("Scripting.FileSystemObject");

var total=0;

var f=fso.GetFolder('.');              // Current folder

var fc=new Enumerator(f.files);

for (; !fc.atEnd(); fc.moveNext()){

 var fileName=fc.item().Name+':Zone.Identifier';

 try

 {

   f1 = fso.OpenTextFile(fileName,2); // If the Zone Identifier does not exist ..

   total++;

   f1.Close();

 }

 catch(e){}                           // .. we don't care

}