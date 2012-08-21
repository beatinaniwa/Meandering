import AssemblyKeys._ // put this at the top of the file

seq(assemblySettings: _*)

name := "ActiveWSI"

version := "1.0"

scalaVersion := "2.9.1"

resolvers += "Local Maven Repository" at "file://"+Path.userHome.absolutePath+"/.m2/repository"

libraryDependencies += "edu.ucla.sspace" % "sspace-wordsi" % "2.0"

libraryDependencies += "edu.ucla.sspace" % "scalda" % "0.0.1"

scalacOptions += "-deprecation"
