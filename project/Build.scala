import sbt._
import Keys._
import PlayProject._

object ApplicationBuild extends Build {

    val appName         = "foxhound"
    val appVersion      = "1.0-SNAPSHOT"

    val appDependencies = Seq(
      // Add your project dependencies here,
      "com.typesafe" %% "play-plugins-redis" % "2.0.1"
    )

    val main = PlayProject(appName, appVersion, appDependencies, mainLang = JAVA).settings(
      // Add your own project settings here      
      resolvers += "Sedis repository" at "http://guice-maven.googlecode.com/svn/trunk"
    )

}
