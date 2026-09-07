import 'dart:io';

void main() async {
  var url1 = Uri.parse("https://firebasestorage.googleapis.com/v0/b/meterviewingproject.firebasestorage.app/o/closecap.glb?alt=media&token=8b24c96a-ca01-4f9b-983c-183810099b4c");
  var url2 = Uri.parse("https://firebasestorage.googleapis.com/v0/b/meterviewingproject.firebasestorage.app/o/opencap.glb?alt=media&token=5e99168a-35c4-4f43-a1a5-6871973569c7");

  var client = HttpClient();
  
  var req1 = await client.getUrl(url1);
  var res1 = await req1.close();
  await res1.pipe(File('assets/FinalClosedCap.glb').openWrite());
  print("Downloaded 1");

  var req2 = await client.getUrl(url2);
  var res2 = await req2.close();
  await res2.pipe(File('assets/FinalOpenCap.glb').openWrite());
  print("Downloaded 2");
}
