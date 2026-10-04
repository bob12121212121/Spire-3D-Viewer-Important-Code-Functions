import 'dart:io';

void main() async {
  var url1 = Uri.parse("MODEL_URL");
  var url2 = Uri.parse("MODEL_URL");

  var client = HttpClient();
  
  var req1 = await client.getUrl(url1);
  var res1 = await req1.close();
  await res1.pipe(File('MODEL_FILE_LOCATION').openWrite());
  print("Downloaded 1");

  var req2 = await client.getUrl(url2);
  var res2 = await req2.close();
  await res2.pipe(File('MODEL_FILE_LOCATION').openWrite());
  print("Downloaded 2");
}
