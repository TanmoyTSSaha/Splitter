import 'package:appwrite/appwrite.dart';
import 'package:splitter/git_ignore.dart';

Client client = Client().setEndpoint('https://cloud.appwrite.io/v1')
    .setProject(appwriteProjectId)
    .setSelfSigned(status: true); // For self signed certificates, only use for development