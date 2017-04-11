import coursier.Keys._

//For what I think are stupid reasons, Coursier won't use SBT's credentials when resolving
//artifacts.  Thus, when using private repositories we have to explicitly tell Coursier
//which credentials to use.  That's what this does
coursierCredentials ++= Seq(
  "Artifactory" -> coursier.Credentials.FromFile(Path.userHome / ".ivy2" / ".credentials")
).toMap

