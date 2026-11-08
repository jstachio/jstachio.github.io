# Rainbow Gum 0.17.2 User Guide

The user guide from the Rainbow Gum javadoc, which is the index.html next to this file, as Markdown for agents and other tools. Links are relative to this file.

## Getting Started <a id="gettingstarted"></a>

First step is to add [Rainbow Gum as a dependency](#installation).

Second if you are not familiar with logging in the Java ecosystem please refer to the excellent [Logging facade SLF4J](https://www.slf4j.org/manual.html) documentation particularly the [logger API](https://www.slf4j.org/apidocs-2.1.0/org/slf4j/Logger.html). What logging levels are and how dotted logger names inherit levels is covered in the JDKs logging facade [`System.Logger.Level`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/System.Logger.Level.html) as well as [Logback effective level](https://logback.qos.ch/manual/architecture.html#effectiveLevel) which Rainbow Gum follows.

The third step is to configure. Most configuration is just configuring logger names to levels, output, and formatting. We will cover the major ways to do this in the following sub sections.

### Using Spring Boot <a id="simple_spring_boot"></a>

If using Spring Boot see **[Spring Boot Integration](#spring_boot)**. The short version: swap `spring-boot-starter-logging` for the Rainbow Gum starter and keep going: Rainbow Gum natively understands almost all of Spring Boot's own documented logging properties (`logging.level.*`, log groups, `logging.file.*`, `logging.pattern.*`, `logging.charset.*`, ANSI control, and structured logging via `logging.structured.format.*` for ECS/GELF/Logstash), so existing `application.properties`/`application.yml` logging config generally keeps working as-is with no application code changes. That makes it a genuinely **low-risk drop-in replacement for Logback**: same properties, same behavior, a simpler and faster implementation underneath.

### Using Other Frameworks <a id="simple_other_frameworks"></a>

Rainbow Gum also integrates with:

- [Micronaut](#micronaut)
- [Helidon](#helidon)
- [Avaje Config](#config_properties) ([rainbowgum-avaje-config](io.jstach.rainbowgum.avaje/module-summary.html))

### Using rainbowgum-simple <a id="simple_testing"></a>

For tests, low depependency applications, or when you prefer the traditional method of letting the logging system handle loading its own configuration, add [rainbowgum-simple](#simple_bundle) and logging works without configuration. Add `logging.properties` to `src/test/resources` (or `src/main/resources` for an application) when you need to customize it. See [Simple logging and properties](#simple_integration) for the Maven dependency and profile options.

### Using RainbowGum Builders <a id="simple_example_builder"></a>

For technical organizations that have many projects it is recommended to use the programmatic builder approach and make a standardized jar (module) shared between all your projects so that logging initialization and configuration is consistent. Assuming we have [installed RainbowGum as a dependency](#installation) a simple configuration example using Java directly and the [`ServiceLoader`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/ServiceLoader.html) is below. It needs [rainbowgum-core](io.jstach.rainbowgum/module-summary.html) and [rainbowgum-pattern](io.jstach.rainbowgum.pattern/module-summary.html) at compile scope (see [Installation](#installation)).

```java
package snippets;

import java.lang.System.Logger.Level;
import java.util.Optional;

import io.jstach.rainbowgum.LogConfig;
import io.jstach.rainbowgum.LogOutput;
import io.jstach.rainbowgum.RainbowGum;
import io.jstach.rainbowgum.pattern.format.PatternEncoderBuilder;
import io.jstach.rainbowgum.spi.RainbowGumServiceProvider.RainbowGumProvider;

public class GettingStartedExample implements RainbowGumProvider {

	@Override
	public Optional<RainbowGum> provide(LogConfig config) {

		return RainbowGum.builder(config) //
			.route(r -> {
				r.level(Level.DEBUG, "com.myapp");
				r.appender("console", a -> {
					a.output(LogOutput.ofStandardOut());
					a.encoder(new PatternEncoderBuilder("console")
						// We use the pattern encoder which follows logback pattern
						// syntax.
						.pattern("[%thread] %-5level %logger{15} - %msg%n")
						// We use properties to override the above pattern if set.
						.fromProperties(config.properties())
						.build());
				});
			}) //
			.optional();
	}

}
```

The class is found with the [`ServiceLoader`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/ServiceLoader.html), so register it in `META-INF/services/io.jstach.rainbowgum.spi.RainbowGumServiceProvider` as a line with its fully qualified name (`snippets.GettingStartedExample` here), or with `provides io.jstach.rainbowgum.spi.RainbowGumServiceProvider with snippets.GettingStartedExample;` in a `module-info.java`. [`RainbowGumServiceProvider`](io.jstach.rainbowgum/io/jstach/rainbowgum/spi/RainbowGumServiceProvider.html) has additional documentation on registering a service loader aware jar. Then make the jar as a runtime dependency to the rest of your applications

### Using System properties <a id="simple_example"></a>

Assuming we have [installed RainbowGum as a dependency](#installation) a simple configuration example using System Properties is below. The `pattern` encoder needs [rainbowgum-pattern](io.jstach.rainbowgum.pattern/module-summary.html) as well (see [Installation](#installation)); without it, leave out the two `encoder` lines to get the default [TTLL](#ttll) format.

```java
  java \
  -Dlogging.appender.console.encoder.uri=pattern \
  -Dlogging.appender.console.encoder.pattern.pattern="[%thread] %-5level %logger{15} - %msg%n" \
  -Dlogging.level.com.myapp=DEBUG \
  -jar myapp.jar
```

What happens with the above is Rainbow Gum will load its default Rainbow Gum via the service loader and use the properties to configure its builders. Unfortunately System properties on the command line can be rather tedious but luckily you can plugin in your own properties system easily.

## Description <a id="description"></a>

Rainbow Gum is a secure, GraalVM native and jlink friendly, modular JDK 21+ SLF4J implementation that aims to be easier to use while leveraging newer JDK technology. The [readme in the Rainbow Gum project](https://github.com/jstachio/rainbowgum) discusses more extensively on the opinionated design and philosophy.

## Project Information <a id="project_information"></a>

- **Source Control**: [https://github.com/jstachio/rainbowgum](https://github.com/jstachio/rainbowgum)
- **Team**: [Adam Gent (agentgt)](https://github.com/agentgt), lead
- **Issues**: [https://github.com/jstachio/rainbowgum/issues](https://github.com/jstachio/rainbowgum/issues)
- **Community**: [https://github.com/jstachio/rainbowgum/discussions](https://github.com/jstachio/rainbowgum/discussions)
- **User Guide**: [This document](index.html)
- **Javadoc**: [This document (modules listing at bottom)](#all-modules-table)

The project follows [semantic versioning](https://semver.org/).

### Requirements <a id="requirements"></a>

1. [Java 21 or greater](https://docs.oracle.com/en/java/javase/21/)
2. Only when [developing extensions](#plugin_guide) that use [rainbowgum-apt](#plugin_guide): a build system that supports running the Java compiler annotation processor, and [`org.jspecify:jspecify`](https://jspecify.dev/) at compile time, since the generated builders use its nullness annotations

The only module needed during runtime is [`java.base`](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/module-summary.html). Core's JSpecify dependency is optional (`requires static`) and is not passed on to your application.

### Limitations <a id="limitations"></a>

Currently Rainbow Gum does not provide support for:

- A configuration file that core loads on its own, like `logback.xml` or `log4j2.xml`. Implicitly loading resources adds to the security surface, so reading a file is an opt-in with [rainbowgum-simple-props](#simple_props). Otherwise configuration comes from system properties or your application's configuration system.
- Calendar/date based log file rotation or compression on a schedule; there is a deliberately basic [built-in size based rolling output](io.jstach.rainbowgum.file/io/jstach/rainbowgum/rolling/RollingFileOutput.html) for keeping a small/desktop app's disk from filling up, and full support for rolling without losing events using an external tool such as logrotate, see the [Rolling Files](#rolling) section.
- [SLF4J Marker](https://www.slf4j.org/api/org/slf4j/Marker.html) support (libraries and applications rarely use it compared to MDC).

If any of these limitations (or others not listed) are a show stopper please let us know by filing an issue. Particularly Markers. If you are using Markers we would like to hear from you.

## How it works <a id="how_it_works"></a>

Most users will use Rainbow Gum through a logging facade such as SLF4J and the only interaction with Rainbow Gum is configuration of output and formatting. Rainbow Gum provides three ways to configure out of the box:

- Simple String key/value properties often derived from System properties / env variables
- Programmatic Java configuration using builders.
- Dependency driven configuration where including a jar as dependency changes behavior automatically

In practice many will use a mixture of all three styles. Rainbow Gum uses the Service Loader to load "default" configurations. Other than logger levels most configuration is simply choosing which jars to be included at runtime and providing some simple properties.

## Architecture <a id="architecture"></a>

Rainbow Gum's design has many superficial similarities to Logback, Log4j2, and Reload4j in that there are Appenders and Encoders as well as how log levels are inherited but most of Rainbow Gum's design is *very different*!

The key difference in Rainbow Gum is that once configured and initialized the logging system is locked in and cannot be changed. Certain parts of the system can be changed at runtime but require opt-in which includes changing levels of logger names.

Another major difference is that Rainbow Gum is highly modularized, immutable and componentized. In other frameworks OOP inheritance is heavily abused and riddled with state management. Furthermore there are components that have too much responsibility which is the case with Appenders in Logback or "Managers" in Log4j2. Furthermore Rainbow Gum **uses zero reflection** other than the Service Loader and follows the builder pattern extensively to separate configuration from immutable runtime components. Almost all components have a builder to programmatically configure and the builders can take flat string key values as configuration. The other logging frameworks use an enormous amount of reflection which slows initialization time. *(While the [`ServiceLoader`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/ServiceLoader.html) is technically reflection it is GraalVM native friendly and is the preferred way for pluggable components in modern JDKs.)*

The results of the above choices make Rainbow Gum far lighter than logback, log4j2, and reload4j particularly in initialization time as well as security surface area.

**The key components expressed in the flow of log events is as follows:**

1. Logging Facade (SLF4J)
2. [`RainbowGum`](io.jstach.rainbowgum/io/jstach/rainbowgum/RainbowGum.html)
3. [`LogRouter`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogRouter.html)
4. [`LogPublisher`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisher.html)
5. [`LogAppender`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.html)
6. [`LogEncoder`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEncoder.html)
7. [`LogOutput`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogOutput.html)

For the exact order components are built and started (useful when debugging a configuration or writing a custom provider), see ["Initialization order"](io.jstach.rainbowgum/io/jstach/rainbowgum/RainbowGum.html) in [`RainbowGum`](io.jstach.rainbowgum/io/jstach/rainbowgum/RainbowGum.html)'s own documentation. In the next sections we will cover [Config](#config), [Alerts, Metrics, and Reporting](#alerts_metrics), [Publishers](#publishers), [Appenders](#appenders), [Encoders](#encoders), and [Outputs](#outputs).

Roughly the hiearchy (through composition) of components is:

1. Routes have a single publisher a level resolver and a list of appenders.
2. Publishers [are given the list of appenders](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisher.PublisherFactory.html) from the route on start.
3. Appenders have a single encoder and output.

For most [level resolving](#level_resolvers), [formatters](#formatters) (which are simplified encoders), and [Outputs](#outputs) are the main points of interest in customizing and configuring.

## Config <a id="config"></a>

A defining characteristic of Rainbow Gum is that it does not have a special configuration format like Logback, Log4j2, and Reload4j (all three use XML as the default). The expectation is that for simple configuration [simple properties interface](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html) analogous to `Function<String,String>` is good enough. For more complicated configuration programmatic configuration using the [builders](io.jstach.rainbowgum/io/jstach/rainbowgum/LogBuilder.html) and service loader should be used.

For implementers of plugins [`LogConfig`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html) allows registering of services and plugins (it also contains the global [`LogProperties`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html) ) however most users will not need to know about it. For those coming from Logback [`LogConfig`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html) is analogous to what Logback calls "Context".

### Properties based <a id="config_properties"></a>

Rainbow Gum out of the box uses System properties for [`LogProperties`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html) but several optional modules provide other properties sources. Other configuration systems may be added as optional modules.

> **Note**
>
> Throughout the documentation [`Properties`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/Properties.html) and [`URI`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/net/URI.html) syntax is used to express configurable properties but it is not a requirement and your configuration system may have a different format like YAML or JSON (see [Custom properties sources](#config_custom_properties)).

The current optional properties modules are:

- [rainbowgum-simple-props](io.jstach.rainbowgum.simple.props/module-summary.html) ([configuration](#simple_props)): loads `logging.properties` files with profiles and a level file, without any third party dependency.
- [rainbowgum-avaje-config](io.jstach.rainbowgum.avaje/module-summary.html): uses [Avaje Config](https://avaje.io/config/) as the properties provider.
- [rainbowgum-spring-boot4](io.jstach.rainbowgum.spring.boot4/module-summary.html) and [rainbowgum-spring-boot3](io.jstach.rainbowgum.spring.boot3/module-summary.html) ([configuration](#spring_boot)): [Spring Boot](https://spring.io/projects/spring-boot) has its own configuration system, so the properties come from the Spring `Environment`, for example `application.properties`, along with Spring Boot's own logging properties.

> **Looking up a property**
>
> Property keys can be looked up in the search bar at the top of every page. Searching for `logging.alerts.fail`, or just `alerts.fail`, finds where that property is documented. Keys with a part you choose are listed with a placeholder, such as `logging.appender.{name}.encoder.uri`, so search for the fixed part around it, such as `encoder.uri`. Every key is listed on the [Search Tags](search-tags.html) page.

An appender's encoder and output are configured under the appender itself: `uri` picks the type, and the type's own settings sit under its URI scheme, so one appender's settings line up in one block:

```properties
logging.appender.{name}.encoder.uri=URI
logging.appender.{name}.encoder.{scheme}.{propertyName}=someStringThatIsConverted
logging.appender.{name}.output.uri=URI
logging.appender.{name}.output.{scheme}.{propertyName}=someStringThatIsConverted
```

For example:

```properties
logging.appender.console.encoder.uri=json5
logging.appender.console.encoder.json5.prettyPrint=spacing
logging.appender.console.output.uri=stdout
logging.appender.console.output.stdout.stream=follow
```

Each type keeps its own keys, so switching `uri` to another type leaves the old type's settings unread rather than misread. An encoder or output built in code without an appender uses the same keys with its own name in place of the appender's. An interpolated key (note key not value) example might be:

```properties
logging.appender.example.encoder.uri=gelf
logging.appender.example.encoder.gelf.host=myhost
logging.appender.example.encoder.gelf.prettyPrint=true
```

> **Note**
>
> The astute might notice that "gelf" does not look like a URI. It is, but URIs missing schemes like the above get normalized so that the path is used as the scheme. Thus `gelf` is actually `gelf:///`.

Because the first property is a URI, its query string is also searched for the other lines' properties, using `{propertyName}` as a bare query parameter with no `logging.appender.{name}.encoder.{scheme}.` (or `logging.appender.{name}.output.{scheme}.`) prefix. So instead of two separate properties, one can write everything on the URI line:

```properties
logging.appender.example.encoder.uri=gelf:///?host=myhost&prettyPrint=true
```

This is not special-cased to `encoder`/`gelf`: every URI-configured sub-component looks its own properties up the same way. The built-in rolling file output is another example:

```properties
logging.appenders=myapp
logging.appender.myapp.output.uri=rolling:///var/log/app.log?maxFileSize=10MB

# the above is equivalent to the more verbose:
logging.appender.myapp.output.uri=rolling:///var/log/app.log
logging.appender.myapp.output.rolling.maxFileSize=10MB
```

#### URI property precedence <a id="config_uri_precedence"></a>

Separately named properties take precedence over URI query parameters. A query parameter is consulted only when the corresponding property is missing.

For example, if both `logging.appender.example.encoder.gelf.prettyPrint` and a `?prettyPrint=` query parameter on the encoder URI are set, the separately named property wins and the URI's value is ignored.

This lets a URI provide single-line defaults that you can override with separate properties without editing the URI itself. This precedence is fixed: every [`LogBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogBuilder.html) uses this lookup order via [`LogProperties.of(java.net.URI, String, io.jstach.rainbowgum.LogProperties)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#of(java.net.URI,java.lang.String,io.jstach.rainbowgum.LogProperties%29).

The [`URI scheme`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/net/URI.html#getScheme(%29) selects the component's plugin, while query parameters provide single-line configuration. This follows the [12 factor](https://12factor.net/) approach to resources and configuration.

<a id="config_uri_credentials"></a>**Do not put credentials in a URI.** Component URIs are shown in [reports](#reporting) and error messages. Rainbow Gum hides user information and all query parameter values when displaying a URI, while retaining its path and parameter names. The read-properties report shows resolved non-sensitive parameters individually. Other property values are redacted when their key looks sensitive, such as `password` or `token`, but that check can only guess.

A property its component marks as sensitive, such as the [OTLP output's](#otlp_output) `headers`, cannot be set in a URI query at all: the component fails to build and says to set the property on its own instead.

Custom components should read URI-valued properties with [`LogProperty.ofURI()`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperty.html#ofURI(%29), which includes the property and source in errors. For URI text from an environment variable or another source, use [`LogProperty.parseURI(String)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperty.html#parseURI(java.lang.String%29). Both omit rejected input from syntax errors, while keeping the parse reason and position. Use [`LogProperty.redactUri(java.net.URI)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperty.html#redactUri(java.net.URI%29) when displaying a successfully parsed URI in diagnostics.

#### Plural keys for enabling/disabling <a id="config_plural"></a>

Because Rainbow Gum's property config model is a lookup of key to value and not a Map like collection special plural keys are used to indicate what is activated. These keys canonical end in `"s"` and are comma separated.

```properties
# appenders that are enabled.
logging.appenders=appender1,appender2
logging.appender.appender1.encoder.uri=...
logging.appender.appender2.output.uri=...
logging.appender.appender3.output.uri=....
```

One empty element at the start or end of a list is ignored, so a value assembled from parts that may be missing (`appender1,${optional}`) still works, while an empty element in the middle is kept and reported by whatever reads the list. Map properties are either a single value (`a=1&b=2`) or, for sources that only hold flat values such as environment variables, a list of keys with one property per value:

```properties
logging.appender.myappender.encoder.gelf.headers.keys=environment,region
logging.appender.myappender.encoder.gelf.headers.environment=prod
logging.appender.myappender.encoder.gelf.headers.region=us east
```

In the above the configuration of `appender3` will not be used and will not produce a configuration error if incorrect. This pattern allows large groups of configuration to be turned on or off similar to profiles in other systems.

#### Implicit default configuration <a id="config_defaults"></a>

Rainbow Gum will happily start with *zero* properties set because most of the properties described above have a built-in default when missing. Nothing here is hidden magic though: the defaults are just what get used when a property lookup falls through to code instead of a configured value, and that same "out of the box" setup can be reproduced explicitly with:

```properties
logging.level=INFO
logging.routes=default
logging.route.default.publisher.uri=sync
# logging.appenders is shorthand for logging.route.default.appenders: it only
# works as a fallback for the "default" route, not any other route name.
logging.appenders=console
logging.appender.console.output.uri=stdout
logging.appender.console.encoder.uri=ttll
```

A few things worth calling out about the above:

- `"logging.appenders"` defaults to just `console`, **not** `console,file`. A file appender is only ever added automatically, and only when ["logging.file.name"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#FILE_PROPERTY) (`logging.file.name`) is itself set, in which case the implicit default becomes `logging.appenders=file,console` (file first, console still included, not replaced). Setting `logging.appenders` yourself to any value, including just `file`, disables this auto-add behavior entirely since an explicit value always wins.
- `"stdout"` and `"ttll"` above are [`URI`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/net/URI.html) schemes (see the plain properties example earlier in this section) resolved through the same [`LogOutputRegistry`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogOutputRegistry.html)/[`LogEncoderRegistry`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEncoderRegistry.html) lookup any explicit `output`/`encoder` value goes through - `ttll` is Rainbow Gum's built-in Logback-esque "Time Thread Level Logger" line formatter, not a Spring Boot-ism.
- `logging.route.default.publisher.uri=sync` means every appender on the default route runs synchronously on the calling thread by default (no background queue/thread) - see [`LogPublisherRegistry`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisherRegistry.html) for the `async` alternative and its own defaults/properties.

#### Custom properties sources <a id="config_custom_properties"></a>

A properties source is an implementation of [`LogProperties`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html), which at its simplest answers [`LogProperties.valueOrNull(String)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#valueOrNull(java.lang.String%29) for a key, much like [`System.getProperty(String)`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/System.html#getProperty(java.lang.String%29). A source can be given to [`LogConfig.Builder.properties(io.jstach.rainbowgum.LogProperties)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#properties(io.jstach.rainbowgum.LogProperties%29), or a module can provide one with a [`RainbowGumServiceProvider.PropertiesProvider`](io.jstach.rainbowgum/io/jstach/rainbowgum/spi/RainbowGumServiceProvider.PropertiesProvider.html), as [rainbowgum-simple-props](#simple_props) and several other framework integrations do.

> **Important**
>
> Rainbow Gum core does not do any interpolation of property values! That is the responsibility of the [`LogProperties`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html) backing implementation and the values retrieved should already be interpolated.
>
> The backing configuration system also must not do any logging, or if it does, allow it to be turned off, intercepted or blocked.

A source backed by a nested format (TOML, HOCON, YAML or JSON) has to handle one kind of key specially. Keys such as `logging.level.com.example` end with a logger name, which can contain dots and any other character, and `logging.level` itself can also have a value. A nested format cannot have a value at a key that is also a table, so a source for one should extend [`LogProperties.AbstractNested`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.AbstractNested.html), which looks the logger name up as a single, quoted member, for example in TOML:

```toml
[logging.level]
root = "warn"
"com.example" = "debug"
"com.example.sub" = "error"
```

`root` is the root logger for every key that ends with a logger name, so `logging.level.root` is the same as `logging.level`, as in Spring Boot. A higher priority source wins whichever of the two it uses.

### Builder based <a id="config_builder"></a>

Rainbow Gum can be configured programmatically through [builders](io.jstach.rainbowgum/io/jstach/rainbowgum/LogBuilder.html). The builders normally will ignore whatever properties (key values) are set externally but most builders can be configured by properties through [`LogBuilder.fromProperties(io.jstach.rainbowgum.LogProperties)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogBuilder.html#fromProperties(io.jstach.rainbowgum.LogProperties%29) and thus a combination of properties and builders can be used.

> <a id="config_builder_service_loader"></a>**Warning: LogConfig.builder() does not use the service loader**
>
> Whether installed modules are discovered with the [`ServiceLoader`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/ServiceLoader.html) depends on which builder is used:
>
> - [`RainbowGum.builder()`](io.jstach.rainbowgum/io/jstach/rainbowgum/RainbowGum.html#builder(%29) and [`RainbowGum.builder(java.util.function.Consumer)`](io.jstach.rainbowgum/io/jstach/rainbowgum/RainbowGum.html#builder(java.util.function.Consumer%29) use it, so the properties providers and configurators of modules on the class or module path are found. The consumer form is for changing one or two things while keeping the rest of the defaults.
> - [`LogConfig.builder()`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html#builder(%29) does not, unless [`LogConfig.Builder.serviceLoader()`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#serviceLoader(%29) is called. It is the explicit path: only what is added to it is used, and startup skips the service loader.
> - [`RainbowGum.builder(io.jstach.rainbowgum.LogConfig)`](io.jstach.rainbowgum/io/jstach/rainbowgum/RainbowGum.html#builder(io.jstach.rainbowgum.LogConfig%29) uses whatever that config was built with.
>
> Without the service loader the properties are only System properties plus anything added to the builder, and components from other modules, such as the [pattern encoder](#pattern) or the `logging.properties` files of [rainbowgum-simple-props](io.jstach.rainbowgum.simple.props/module-summary.html), are missing. Configuration that names a missing scheme, such as `logging.appender.console.encoder.uri=pattern`, then fails with an error saying the module is present but was not loaded. Call [`LogConfig.Builder.serviceLoader()`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#serviceLoader(%29) or add the module's configurator with [`LogConfig.Builder.configurator(io.jstach.rainbowgum.spi.RainbowGumServiceProvider.Configurator)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#configurator(io.jstach.rainbowgum.spi.RainbowGumServiceProvider.Configurator%29). Modules found only through the service loader without a scheme, such as the JUL bridge, are simply not installed, with no error.

### Config Change during runtime <a id="config_change"></a>

While most of the logging components in Rainbow Gum are immutable and cannot be changed during runtime there are some exceptions including custom components.

A supporting configuration system (a LogProperties provider) can notify that there has been a change by using the [Change Publisher](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html#changePublisher(%29). This is how level resolving changes can be published.

Config change is by default off even on supporting configuration systems and can only be turned on by setting ["logging.change.mode"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#CHANGE_MODE_PROPERTY) to `on` (or with [`LogConfig.Builder.changeMode(io.jstach.rainbowgum.LogConfig.ChangePublisher.ChangeMode)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#changeMode(io.jstach.rainbowgum.LogConfig.ChangePublisher.ChangeMode%29)). Which loggers may change is then chosen per logger with ["logging.change.logger"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#CHANGE_LOGGER_PREFIX).

## Router <a id="router"></a>

A Router has a [`LevelResolver`](io.jstach.rainbowgum/io/jstach/rainbowgum/LevelResolver.html), appenders and a [Publisher](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisher.html). A Level Resolver takes a logger name and produces a [`level`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/System.Logger.Level.html). The logging facade implementation then decides based on the level whether or not to construct an event. It then passes the event to the router which in turn uses the publisher to schedule the event. For those familiar with other logging frameworks **Rainbow Gum has no actual concept of named "Loggers"** but a route from a router is the closest analog.

When configuring routers you are configuring [`Level Resolvers`](io.jstach.rainbowgum/io/jstach/rainbowgum/LevelResolver.html) which are logger names to levels, which publisher to use and which appenders should be associated with the publisher. We call this configuration a *"route"*. As discussed later on a publisher has appenders and appenders have outputs thus an important consequnce of this is if you want outputs to have different level thresholds (e.g. a debug.log and an error.log) you will need multiple routes.

Example configuring router with properties using ["logging.route.{name}."](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#ROUTE_PREFIX) with name set to "`example`".

```properties
logging.routes=example
logging.route.example.appenders=appender1,appender2
logging.route.example.publisher.uri=async
logging.route.example.level.com.mycompany=DEBUG
```

If ["logging.routes"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#ROUTES_PROPERTY) is not set the route name is assumed to be ["default"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogRouter.Router.html#DEFAULT_ROUTER_NAME). Notice that routes can contain their own level configuration and thus a route is a way to group appenders with the same level resolving.

### Level Resolvers <a id="level_resolvers"></a>

As mentioned previously routers have a level resolver. A level resolver simply resolves the [level](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/System.Logger.Level.html) (an enum) from a logger name (String). Because of [`LevelResolver`](io.jstach.rainbowgum/io/jstach/rainbowgum/LevelResolver.html) functional interface we can chain them with *fallbacks*. An important fallback level resolver that almost all routers use is the global level resolver. These levels can be configured with [`properties`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html) where logger names prefixed with ["logging.level"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#LEVEL_PREFIX) as the key and the level as the value. Below is an example:

```properties
# Descendant of "com.mycompany"
logging.level.com.mycompany.stuff=DEBUG
# Ancestor to "com.mycompany.stuff"
logging.level.com.mycompany=INFO
logging.level=ERROR
```

[Parsing of levels from property values](io.jstach.rainbowgum/io/jstach/rainbowgum/LevelResolver.html#parseLevel(java.lang.String%29) accepts `trace`, `debug`, `info`, `warn`, `warning`, `error`, `off`, `all` (the same as `trace`), and the JUL names `finest`, `fine`, and `severe`, ignoring case. Other JUL names such as `config` and Log4j's `fatal` are not accepted. The logger name is case sensitive.

The root level is the bare `logging.level` key or, as in Spring Boot, `logging.level.root`. The same goes for every key that ends with a logger name, such as `logging.change.logger.root`. A logger literally named `root` inherits the root default, but a [group can give it its own settings](#level_groups_difficult_names).

Although not required most level resolvers including the global follow an inheritance or prefix model where `com.mycompany.stuff.foo` will resolve to `DEBUG` and `com.mycompany.bar` will resolve to `INFO` and anything not prefixed with `com.mycompany` will resolve to `ERROR`. An analog is to think of the "`.`" as directory path separators like in filesystems and resolution happens by going up the directories. This behavior is stated more formally in [Logback's Effective Level](https://logback.qos.ch/manual/architecture.html#effectiveLevel) which is what Rainbow Gum follows as well.

#### Changing Levels at Runtime <a id="changing_resolving"></a>

Rainbow Gum **by default assumes Level Resolvers are cached or static and will never change at runtime.** This is a critical feature of Rainbow Gum as it *allows facade loggers like in SLF4J to be lower overhead than almost all other logging frameworks!* That being said RainbowGum allows levels to be changed at runtime if the backing configuration framework supports reloading and the logger name is allowed to be changed.

Below is an example of configuring to allow *"changing" loggers*

```properties
# this is required to turn on level changing.
logging.change.mode=on
# only logger names starting with com.mycompany can have their levels changed.
logging.change.logger.com.mycompany=level
```

To fire off that configuration has changed the [`LogConfig.ChangePublisher`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.ChangePublisher.html) is used and depending on configuration backend may require a manual [`publish call`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.ChangePublisher.html).

#### Route Level Priority <a id="route_level_priority"></a>

A router's [level resolver](io.jstach.rainbowgum/io/jstach/rainbowgum/LevelResolver.html) is actually a chain: the route's *own* level configuration is checked first, and only if the route has no opinion for a particular logger name does resolution fall through to the global level resolver. This means a route's level configuration always takes priority over the global configuration for any logger name the route has configured regardless of whether the global resolver has a deeper/more specific prefix match for that same name.

```properties
# global: specific override
logging.level.com.mycompany.orders=DEBUG
# route "errors": broad override
logging.route.errors.level=ERROR
```

Without this priority rule a naive merge of the two resolvers into one combined prefix walk would let the more specific global entry (`com.mycompany.orders=DEBUG`) win, silently defeating the route's intent to restrict itself to `ERROR` and above. Because the route's resolver is consulted first and independently of the global one, the *"errors"* route above correctly resolves `com.mycompany.orders` to `ERROR` no matter what the global resolver says about that name. A route only falls back to the global resolver for logger names it has not configured an opinion about itself.

#### Level Groups <a id="level_groups"></a>

Rainbow Gum out of the box supports [Spring Boot like Log Groups](https://docs.spring.io/spring-boot/3.3.2/reference/features/logging.html#features.logging.log-groups). However unlike Spring Boot groups are not enabled unless ["logging.groups"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#GROUPS_PROPERTY) contains the group. (*this is largely because Spring Boots configuration model is like a Map and Rainbow Gums a Function.*)

Furthermore group levels but not group definitons can be assigned on the router itself. Using Spring Boots example:

```properties
# This is required otherwise the tomcat group will not be resolved
logging.groups=tomcat
logging.group.tomcat=org.apache.catalina,org.apache.coyote,org.apache.tomcat
logging.level.tomcat=trace
logging.route.myroute.level.tomcat=info
```

In the above `org.apache.catalina`, `org.apache.coyote`, and `org.apache.tomcat` and their descedants will resolve to `INFO` for "`myroute`" but `TRACE` for other routes. Note that just like logger names groups are case sensitive.

##### Groups for difficult logger names <a id="level_groups_difficult_names"></a>

A group is also the easiest way to configure a logger whose name is difficult to write as a property key. The logger names go in the group's value, and only the group name has to be a key. This matters most with [environment variables](#simple_props): a key maps to a variable name by replacing `.` with `_`, and shells only allow letters, digits and `_` in variable names, so there is no way to write a key for a logger named `access-log` or `com.example.Router$Handler`. With a group:

```shell
export RAINBOWGUM_groups=web
export RAINBOWGUM_group_web='access-log,com.example.Router$Handler'
export RAINBOWGUM_level_web=DEBUG
```

The same groups work for [changing loggers](#changing_resolving) and caller info: `logging.change.logger.web=level` and `logging.caller.logger.web=true` apply to the loggers in `web` and their children. As with levels, a logger's own key wins over a group, and the last group listed in `logging.groups` wins when a logger is in more than one. Group values are comma separated, so a logger name containing a comma cannot be listed.

A group can also configure a logger literally named `root`, since `logging.level.root` is reserved for the root default. For example:

```properties
logging.level.root=warn
logging.groups=literalRoot
logging.group.literalRoot=root
logging.level.literalRoot=debug
```

The logger named `root` and its descendants resolve to `DEBUG`, while other loggers inherit `WARNING`. More specific logger settings still win. The same group can set `logging.change.logger.literalRoot` and `logging.caller.logger.literalRoot` without changing their root defaults.

#### Additivity <a id="Additivity"></a>

Those familiar with Logback and Log4j2/1 "additivity" may wonder how that is achieved. Additivity is associated with a logger name in those frameworks and means that the logger level settings will apply to other appenders associated with logger (name) and its ancestors. If false the settings only apply to the associated appenders at that logger and descendants.

In rainbowgum the configuration including logger name to level is done on the route and rainbowgum allows multiple appenders on a route and multiple routes.

For example let us assume we want logger name `com.mycompany` (and descendants) at `DEBUG` or greater to go to a file called `mycompany.log` and `WARN` for console `com.mycompany` (and everything else). In Logback and others this is achieved by setting the appenders on `com.mycompany` and `additivity=false` but in rainbowgum this is done by configuring separate routes:

```properties
logging.level=INFO
logging.routes=console,mycompany
logging.route.mycompany.appenders=mycompany
logging.route.mycompany.level.com.mycompany=DEBUG
logging.route.console.level=WARN
logging.route.console.appenders=console
logging.appender.mycompany.output.uri=file:///./mycompany.log
logging.appender.console.output.uri=stdout
```

In the above the route *"console"* will output log entries that will only have `WARN` or greater (`ERROR`) to `stdout` (terminal/console output). The route *"mycompany"* will log `DEBUG` and greater for `com.mycompany` (and descendants like `com.mycompany.something`) to the file `mycompany.log`. However the *"mycompany"* route has no opinion about any other logger name, so for everything else it falls back to the global level (`INFO`). That means at this point `mycompany.log` is also catching `INFO` and greater from every other logger, not just `com.mycompany`.

To actually isolate `mycompany.log` to just `com.mycompany` (and descendants) the route needs to stop falling back to the global level for every other logger name. We do this by giving the route its own default of `OFF`, which the more specific `com.mycompany` override above still takes priority over:

```properties
logging.route.mycompany.level=OFF
```

Even more sophisticated level resolution can be done programmatically with builder based configuration and custom Level Resolvers.

### Caller Information <a id="caller_info"></a>

Somewhat related to level resolvers and config change is how to enable [caller info](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEvent.html#callerOrNull(%29). [`LogEvent.Caller`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEvent.Caller.html) has stack trace like information on where the logging call was made. It is incredibly slow so like changing loggers it must be enabled and you can enable it with logger name inheritance so not all loggers will be slow. Caller info does not need `logging.change.mode`. Below is an example of configuring caller info for a set of logger names:

```properties
# only logger names starting with com.mycompany will have caller info
logging.caller.logger.com.mycompany=true
```

Caller info is decided once, when a logger is created, and does not change afterward. Note that ["logging.caller.logger"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#CALLER_LOGGER_PREFIX) is resolved completely independently of ["logging.change.logger"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#CHANGE_LOGGER_PREFIX): each walks its own logger name inheritance separately, so enabling caller info for `com.mycompany` does not also make `com.mycompany` level changeable, and a more specific `logging.change.logger.com.mycompany.app` entry does not clobber `com.mycompany.app`'s inherited caller info the way it would if the two shared one property. The value is a [`LogEvent.Caller.CallerType`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEvent.Caller.CallerType.html) (or `true`/`false`), where [`BASIC`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEvent.Caller.CallerType.html#BASIC) (what `true` means today) is the only strategy implemented so far.

## Publishers <a id="publishers"></a>

A [`LogPublisher`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisher.html) schedules delivery of a [`LogEvent`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEvent.html) to a group of Appenders. Publishers come in two types:

1. [synchronous](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisher.SyncLogPublisher.html) (the default)
2. [asynchronous](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisher.AsyncLogPublisher.html)

An appender should only belong to one publisher. In other logging frameworks like Logback and Reload4J this responsibility is handled by an Appender but Rainbow Gum separates this responsibility out.

Since publishers are where Rainbow Gum's threading concerns live, this is worth mentioning here: setting ["logging.global.threadLocal"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#GLOBAL_THREAD_LOCAL_PROPERTY) to `forbid` is a guarantee of no [`ThreadLocal`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ThreadLocal.html) anywhere in the logging path: it forces every appender off [`ThreadLocal`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ThreadLocal.html)-backed buffer strategies and, if the SLF4J module is in use, disables MDC too, which is the same effect as combining the appender and MDC options above individually.

> **Note**
>
> If you want some appenders to be async and others sync you just create multiple routes.

### Batch swap <a id="publisher_batch_swap"></a>

[`BlockingQueueAsyncLogPublisher`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BlockingQueueAsyncLogPublisher.html) was intended as an example and must not be used in production. It is deprecated for removal in the next release. Batch swap is the built-in async queue publisher.

The default async implementation is [`BatchSwapAsyncLogPublisher`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisher.html). Producers fill a bounded buffer while a single worker writes the previous batch to its appenders. Producers block by default when the pending buffer is full. Each buffer holds up to [`bufferSize`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#bufferSize(java.lang.Integer%29) events (1024 by default), so up to two batches may be retained, plus events held by blocked callers. The [`events.queued`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html#EVENTS_QUEUED_METRIC) metric counts pending events, excluding the batch being written.

#### Configuration <a id="publisher_batch_swap_configuration"></a>

An example configuring a route named "example" to use the default async publisher:

```properties
logging.route.example.publisher.uri=async
logging.route.example.publisher.async.bufferSize=1024
logging.route.example.publisher.async.shutdownTimeout=10000
```

Publisher settings are under the scheme written in `uri`, so the [`async`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisherRegistry.html#ASYNC_SCHEME) settings above apply to whichever publisher is registered as [`async`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisherRegistry.html#ASYNC_SCHEME).

To select batch swap explicitly, even if a plugin or future release changes the default async publisher, use [`batchswap`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisherRegistry.html#BATCH_SWAP_SCHEME). It accepts the same settings, under its own scheme, or as URI options:

```properties
logging.route.example.publisher.uri=batchswap
logging.route.example.publisher.batchswap.bufferSize=1024
# or
logging.route.example.publisher.uri=batchswap:///?bufferSize=1024&shutdownTimeout=10000
```

For programmatic configuration, use [`BatchSwapAsyncLogPublisher.builder(String)`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisher.html#builder(java.lang.String%29). Its generated builder can load the same properties with [`fromProperties(properties)`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#fromProperties(io.jstach.rainbowgum.LogProperties%29); present properties override values already set on the builder. The [`shutdownTimeout`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#shutdownTimeout(java.time.Duration%29) setter accepts a [`Duration`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/time/Duration.html), while the property is expressed in milliseconds.

#### Overload handling <a id="publisher_batch_swap_overload"></a>

Overload handling is explicit. The defaults retain blocking behavior without early discarding:

- [`overflow=block`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#overflow(io.jstach.rainbowgum.publisher.BatchSwapAsyncLogPublisher.Overflow%29) waits for space when full. [`overflow=drop`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#overflow(io.jstach.rainbowgum.publisher.BatchSwapAsyncLogPublisher.Overflow%29) discards the incoming event at any level when full. It avoids waiting for capacity, but still acquires a short publisher lock and may invoke an alert listener.
- [`discardThreshold`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#discardThreshold(java.lang.Integer%29) reserves pending slots for higher-priority events. Zero (the default) disables early discarding. Otherwise, events at or below [`discardLevel`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#discardLevel(java.lang.System.Logger.Level%29) are discarded when remaining slots are at or below the threshold. The threshold must be less than [`bufferSize`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#bufferSize(java.lang.Integer%29), and excludes the batch currently being written.
- [`discardLevel=info`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#discardLevel(java.lang.System.Logger.Level%29) is the default cutoff for early discarding. For example, `debug` retains INFO events too. `off` disables early discarding.

For example, reserve 128 of 1024 slots for warnings and errors, blocking those events if the buffer fills ([`discardLevel=info`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#discardLevel(java.lang.System.Logger.Level%29) and [`overflow=block`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#overflow(io.jstach.rainbowgum.publisher.BatchSwapAsyncLogPublisher.Overflow%29) are the defaults, shown for clarity). Use [`overflow=drop`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#overflow(io.jstach.rainbowgum.publisher.BatchSwapAsyncLogPublisher.Overflow%29) if even warnings and errors should be discarded instead of waiting:

```properties
logging.route.example.publisher.uri=async
logging.route.example.publisher.async.bufferSize=1024
logging.route.example.publisher.async.discardThreshold=128
logging.route.example.publisher.async.discardLevel=info
logging.route.example.publisher.async.overflow=block
```

The same options are available under `publisher.batchswap` when selecting [`batchswap`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisherRegistry.html#BATCH_SWAP_SCHEME), or as URI query parameters. Accepted events are never evicted, and output always runs on the worker. Discarding is never silent: every event discarded by these options increments the [`events.discarded`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html#EVENTS_DISCARDED_METRIC) [metric](#metrics), and the first discard for each option produces a warning [alert](#alerts). Later discards are only counted. Events lost for other reasons, such as a failed worker, count as [`events.dropped`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html#EVENTS_DROPPED_METRIC) with an error alert instead.

#### Shutdown <a id="publisher_batch_swap_shutdown"></a>

On close, the publisher drains queued events and calls already waiting for space before closing its appenders. New calls are rejected once shutdown begins. Close waits up to [`shutdownTimeout`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#shutdownTimeout(java.time.Duration%29) milliseconds (10 seconds by default). If delivery takes longer, close returns with an [alert](#alerts); the worker continues draining and closes the appenders afterward. The worker is never interrupted during shutdown. The worker only drains while the JVM is running, so events still queued when the JVM exits are lost: [`shutdownTimeout`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#shutdownTimeout(java.time.Duration%29) is how long close waits for them.

Rejected events increment [`events.dropped`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html#EVENTS_DROPPED_METRIC), with one error alert per rejection reason for each publisher. This covers logging before start, after shutdown begins, recursively from the worker, or after worker failure. A producer interrupted while waiting for space also drops its event and retains its interrupt flag. An interrupted caller can still enqueue when space is available.

### Disruptor <a id="publisher_disruptor"></a>

Rainbow Gum has an experimental async publisher that uses the LMAX Disruptor ringbuffer: [rainbowgum-disruptor](io.jstach.rainbowgum.disruptor/module-summary.html). If the jar is found on start it will replace the default async publisher, and it can also be selected explicitly as [`disruptor`](io.jstach.rainbowgum.disruptor/io/jstach/rainbowgum/disruptor/DisruptorConfigurator.html#DISRUPTOR_SCHEME). Its only setting is [`bufferSize`](io.jstach.rainbowgum.disruptor/io/jstach/rainbowgum/disruptor/DisruptorLogBuilder.html#bufferSize(java.lang.Integer%29), which must be a power of two; it has no [`shutdownTimeout`](io.jstach.rainbowgum/io/jstach/rainbowgum/publisher/BatchSwapAsyncLogPublisherBuilder.html#shutdownTimeout(java.time.Duration%29).

## Appenders <a id="appenders"></a>

An [appender](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.html) contains an [Encoder](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEncoder.html) and an [`Output`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogOutput.html). Unlike other logging frameworks there are no custom Appenders as most of the work is done by the encoder and output. That is an appender can be mostly thought of as a tuple of encoder and output as well as it supervises both.

Appenders are associated to the previously mentioned route. Like previously mentioned when a route is not given a name it is automatically named ["default"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogRouter.Router.html#DEFAULT_ROUTER_NAME). Thus to register appenders to the default route one can use:

```properties
logging.appenders=myappender
# an example config of appender
logging.appender.myappender.type=reuse_buffer
```

If the route is named say "example" then configuration of the appenders can be done like:

```properties
logging.route.example.appenders=myappender
# an example config of appender
logging.appender.myappender.type=reuse_buffer
```

### Appender Configuration <a id="appender_config"></a>

Appenders can be configured either programmatically through the [`builder`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.Builder.html) or through properties.

- **[Output](#outputs)**: ["logging.appender.{name}.output.uri"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.html#APPENDER_OUTPUT_PROPERTY) = URI
- **[Encoder](#encoders)**: ["logging.appender.{name}.encoder.uri"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.html#APPENDER_ENCODER_PROPERTY) = URI
- **[Type](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderType.html)**: ["logging.appender.{name}.type"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.html#APPENDER_TYPE_PROPERTY) = a single [`LogAppender.AppenderType`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderType.html)
- **[Flags](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderFlag.html)**: ["logging.appender.{name}.flags"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.html#APPENDER_FLAGS_PROPERTY) = List of [`LogAppender.AppenderFlag`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderFlag.html)

Most appender types reuse a buffer per thread ([`ThreadLocal`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ThreadLocal.html)) for low lock contention. For deployments that want no [`ThreadLocal`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ThreadLocal.html) anywhere in the logging path, [`LogAppender.AppenderType.LOCK_NEW_BUFFER`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderType.html#LOCK_NEW_BUFFER) allocates a fresh buffer per event instead, trading that guarantee for a per-event allocation. An important Appender Flag is [`LogAppender.AppenderFlag.DISABLE_IMMEDIATE_FLUSH`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderFlag.html#DISABLE_IMMEDIATE_FLUSH) which will tell the output to not flush after each event. Flushing after each event is enabled by default to follow [12 Factors requirements of events written unbuffered](https://12factor.net/logs) synchronously; this flag should be used to opt out of that for performance reasons.

### Appender Reentry Protection <a id="appender_reentry"></a>

A problem that can occur in any logging framework is if an output, appender, or encoder does logging which if synchronous will usually cause a stackoverflow and if asynchronous an infinite stream of events. Let us create a hypothetical example where we have an Output that uses a message queue client. The message queue client uses SLF4J for logging. If an event is sent that causes the message queue client to log an event and that event is not discarded and the output client then logs the event it created you get reentry in a synchronous publisher. With asynchronous it is far worse as there will be less immediate evidence that something is broken and instead a never ending supply of log entries.

Some logging frameworks like [logback provide reentry protection](https://logback.qos.ch/manual/appenders.html#AppenderBase) usually through threadlocals but one must understand this only works if logging is synchronous (synchronous publisher), hurts performance, and is just a misleading bandaid over a potential serious problem if the events are being dropped (which logback does by default). **That is why Rainbow Gum does not provide reentry protection unless requested!** However the flags [`LogAppender.AppenderFlag.REENTRY_DROP`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderFlag.html#REENTRY_DROP) and [`LogAppender.AppenderFlag.REENTRY_LOG`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderFlag.html#REENTRY_LOG) can be used to provide similar and arguably better protection than logback.

**Overall the real solution is to fix the output so that it filters events that would cause such behavior or ideally not do any logging.**

## Encoders <a id="encoders"></a>

Encoders encode an event into binary. Because most encoding is text based RainbowGum has the concept of [`LogFormatter`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogFormatter.html) which can be turned into an Encoder and is covered in the next section. However there are scenarios where generating bytes directly is desirable.

Rainbow Gum JSON encoder module [rainbowgum-json](io.jstach.rainbowgum.json/module-summary.html) has efficient JSON encoders. *They are encoders instead of formatters (which are covered next) because writting JSON as bytes is more efficient.*

Configuring an [appenders encoder with properties](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#APPENDER_ENCODER_PROPERTY) looks something like:

```properties
logging.appenders=myappender
logging.appender.myappender.encoder.uri=gelf
logging.appender.myappender.encoder.gelf.host=myhost
logging.appender.myappender.encoder.gelf.prettyPrint=true
```

The above will use the GELF JSON encoder, set its required `host`, and configure it to pretty print.

Encoders should have a builder as well to configure programmatically and the builders javadoc has the string properties that can configure it.

A typical practice is to use a [pattern encoder](#pattern) that produces human readable logs for development and a [JSON encoder](#json_encoders) for production switched out based on configuration.

### JSON Encoders <a id="json_encoders"></a>

Rainbow Gum provides several JSON encoders in the [rainbowgum-json](io.jstach.rainbowgum.json/module-summary.html) module. Unless `prettyPrint` is enabled the JSON encoders included follow the [JSON Lines](https://jsonlines.org/) standard as well as of course the JSON standard [RFC-8259](https://datatracker.ietf.org/doc/html/rfc8259). However note that there is no standard on time format in JSON so the formatting of log event time can vary from JSON encoders depending on the formats specification. The module also can be used to create ones own custom JSON encoders. The following sections cover the various encoders.

#### GELF JSON Encoder <a id="gelf"></a>

[`GelfEncoderBuilder`](io.jstach.rainbowgum.json/io/jstach/rainbowgum/json/encoder/GelfEncoderBuilder.html) - The [Graylog Extended Log Format (GELF)](https://go2docs.graylog.org/current/getting_in_log_data/gelf_format.html) JSON encoder follows the GELF JSON specification linked above with translations of levels that are roughly similar to syslog. Notice that although the GELF specification does not require [JSON Lines](https://jsonlines.org/) this encoder will keep each event on its own line unless `prettyPrint` is enabled. Key values are additional fields; a key value named like an additional field the encoder writes, or `id`, gets a `keyValues.` prefix (`_keyValues.level`).

```properties
logging.appenders=myappender
logging.appender.myappender.encoder.uri=gelf
logging.appender.myappender.encoder.gelf.host=somehost
```

#### ECS JSON Encoder <a id="ecs"></a>

[`EcsEncoderBuilder`](io.jstach.rainbowgum.json/io/jstach/rainbowgum/json/encoder/EcsEncoderBuilder.html) - [Elastic Common Schema (ECS)](https://www.elastic.co/guide/en/ecs-logging/java/current/index.html) JSON, URI scheme ["ecs"](io.jstach.rainbowgum.json/io/jstach/rainbowgum/json/encoder/EcsEncoder.html#ECS_SCHEME). Two shapes are supported: by default field names are the flattened, dotted ECS names (e.g. `"log.level"`) as the reference [ecs-logging-java](https://github.com/elastic/ecs-logging-java) implementation writes them; setting `logging.appender.{name}.encoder.ecs.structured=true` instead nests fields as JSON objects (e.g. `"log":{"level":...}`) matching [Spring Boot's ECS structured logging format](https://docs.spring.io/spring-boot/reference/features/logging.html). Key values are written as top-level fields using their own key name, except a key value named like a field the encoder writes, which goes in a nested `keyValues` object (`keyValues.` prefixed fields in the flattened shape) so no field is written twice:

```properties
logging.appenders=myappender
logging.appender.myappender.encoder.uri=ecs
logging.appender.myappender.encoder.ecs.serviceName=myapp
logging.appender.myappender.encoder.ecs.structured=true
```

#### Logstash JSON Encoder <a id="logstash"></a>

[`LogstashEncoderBuilder`](io.jstach.rainbowgum.json/io/jstach/rainbowgum/json/encoder/LogstashEncoderBuilder.html): format produced by [logstash-logback-encoder](https://github.com/logfellow/logstash-logback-encoder)'s `LogstashEncoder`, URI scheme ["logstash"](io.jstach.rainbowgum.json/io/jstach/rainbowgum/json/encoder/LogstashEncoder.html#LOGSTASH_SCHEME). Key values are flattened top-level fields (matching the reference implementation), except a key value named like a field the encoder writes, which goes in a nested `keyValues` object, and `@timestamp` is rendered with an offset using [a configurable zone](io.jstach.rainbowgum.json/io/jstach/rainbowgum/json/encoder/LogstashEncoder.html#zoneId(%29) (defaults to the system default zone):

```properties
logging.appenders=myappender
logging.appender.myappender.encoder.uri=logstash
logging.appender.myappender.encoder.logstash.zoneId=UTC
```

#### Logback JSON Encoder <a id="logback_json"></a>

[`LogbackJsonEncoderBuilder`](io.jstach.rainbowgum.json/io/jstach/rainbowgum/json/encoder/LogbackJsonEncoderBuilder.html): resembles [Logback's own opinionated JSON encoder](https://logback.qos.ch/manual/encoders.html#JsonEncoder), URI scheme ["logback"](io.jstach.rainbowgum.json/io/jstach/rainbowgum/json/encoder/LogbackJsonEncoder.html#LOGBACK_SCHEME). Nests key values under a `mdc` object and, for throwables, a `throwable` object with a `stepArray` of stack frames (recursing into `cause`):

```properties
logging.appenders=myappender
logging.appender.myappender.encoder.uri=logback
```

#### Post Processors <a id="post_processors"></a>

Encoders backed by a formatter (the default TTLL encoder, the pattern encoder, and any [`LogEncoder.of(io.jstach.rainbowgum.LogFormatter)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEncoder.html#of(io.jstach.rainbowgum.LogFormatter%29)) can rewrite the finished text of each event with [post processors](io.jstach.rainbowgum/io/jstach/rainbowgum/LogFormatter.PostProcessor.html), listed by name:

```properties
logging.appender.console.encoder.postProcessors=crlf,journald
```

They run in the order listed, each on the text the previous one left, so order matters: `crlf,journald` keeps a multi-line event, such as one with a stack trace, as one journal entry, while `journald,crlf` prefixes every original line before joining them. Post processors change only that encoder's text, not the event, so other appenders still see the original values. Encoders that write bytes directly, such as the JSON encoders, do not use post processors. The built in ones are [`LogFormatter.StandardPostProcessor`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogFormatter.StandardPostProcessor.html):

- `journald` starts every line, including stack trace lines, with the event's syslog severity (`<3>` for error), which systemd's journal reads as the line's priority.
- `crlf` escapes line breaks inside an event so it stays on one line and untrusted input cannot forge extra log lines. It also escapes backslashes, control characters other than tab, and Unicode line and paragraph separators. Every ESC character is escaped, including ANSI colours and styles from the formatter. One final LF or CRLF is preserved as the record separator. Other Unicode text is unchanged.

The built in names are registered when the config is created, so a custom post processor needs a name of its own. Custom post processors are registered under the name used in the property, usually from a [`RainbowGumServiceProvider.Configurator`](io.jstach.rainbowgum/io/jstach/rainbowgum/spi/RainbowGumServiceProvider.Configurator.html), with [`LogFormatter.PostProcessor.register(io.jstach.rainbowgum.ServiceRegistry, String, io.jstach.rainbowgum.LogFormatter.PostProcessor.Provider)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogFormatter.PostProcessor.html#register(io.jstach.rainbowgum.ServiceRegistry,java.lang.String,io.jstach.rainbowgum.LogFormatter.PostProcessor.Provider%29):

```java
PostProcessor.register(config.serviceRegistry(), "maskDigits", (encoderName, c) -> new MaskDigits());
```

## Formatters <a id="formatters"></a>

Formatting of log events as textual data is so common that Rainbow Gum has special support for that with [`LogFormatter`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogFormatter.html). While formatters can at high-level be considered an encoder for technical API reasons they are not. However any formatter can be converted to an encoder with [`LogEncoder.of(io.jstach.rainbowgum.LogFormatter)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEncoder.html#of(io.jstach.rainbowgum.LogFormatter%29).

**Many of the following formatters are also encoders and can thus be referenced like normal encoders using URIs.**

### TTLL Formatter <a id="ttll"></a>

TTLL (Time, Thread, Level, Logger) is the default text format and needs no extra module. By default each line also carries the event's key values (MDC and other context), percent encoded in braces after the logger name:

```java
12:00:00.123 [main] INFO  com.example.App {requestId=42&user=Ada%20Lovelace} - hello world
12:00:00.123 [main] INFO  com.example.App - started
```

Key values are on by default because modern logging relies on them. Seeing them shows developers that context such as request and trace ids is actually reaching their logs, and a feature that is never shown is a feature nobody knows exists. Agents reading logs also benefit from the extra context. With wide screens and color the extra text costs little, and `keyValues=none` turns it off. Each part can be changed with properties of the encoder, much like slf4j-simple's options, so changing the key values format or dropping the time does not require the pattern module:

```properties
logging.appender.console.encoder.ttll.timestamp=iso
logging.appender.console.encoder.ttll.keyValues=json5
```

```java
2026-10-05T12:00:00.123Z [main] INFO  com.example.App {requestId:"42",user:"Ada Lovelace"} - hello world
```

- [`timestamp`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/TTLLFormatterBuilder.html#timestamp(io.jstach.rainbowgum.LogFormatter%29): `ttll` (default, `HH:mm:ss.SSS` UTC), `iso`, `none`, or a `DateTimeFormatter` pattern in UTC.
- [`thread`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/TTLLFormatterBuilder.html#thread(io.jstach.rainbowgum.LogFormatter%29): `name` (default), `id`, or `none`.
- [`level`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/TTLLFormatterBuilder.html#level(io.jstach.rainbowgum.LogFormatter%29): `padded` (default), `plain`, `bracketed`, or `none`.
- [`logger`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/TTLLFormatterBuilder.html#logger(io.jstach.rainbowgum.LogFormatter%29): `full` (default), `short` (last name component), or `none`.
- [`keyValues`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/TTLLFormatterBuilder.html#keyValues(io.jstach.rainbowgum.LogFormatter%29): `percent` (default), `json`, `json5`, or `none`. JSON writes `{"requestId":"42"}`; JSON5 leaves valid identifier keys unquoted, as in `{requestId:"42"}`. Key values are written in braces; `none` leaves out the key values and their braces.
- [`keyValuesWhenEmpty`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/TTLLFormatterBuilder.html#keyValuesWhenEmpty(io.jstach.rainbowgum.format.TTLL.KeyValuesWhenEmpty%29): whether the braces are written for an event with no key values. `auto` (default) leaves them out for `percent` and `json5` and writes `{}` for `json`, since whatever reads JSON key values expects an object on every line; `omit` (alias `false`) leaves them out and is rejected with `json` for the same reason, so a production profile that switches to JSON cannot silently drop objects; `show` (alias `true`) always writes them, for a fixed line shape.
- [`color`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/TTLLFormatterBuilder.html#color(io.jstach.rainbowgum.format.TTLL.ColorMode%29): whether to color. `default` (alias `true`, used when not set) colors with the theme, or rainbowgum when no theme is set, if the console supports ANSI; `detect` colors the same way but only when a theme is set; `force` colors with the theme, or rainbowgum, regardless of ANSI support; `off` (alias `false`) never colors. `logging.global.ansi.mode` sets the default: `off` turns it to off and `on` to force, and the default encoder of outputs that are not a console, such as files, is never colored unless `color` is set.
- [`theme`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/TTLLFormatterBuilder.html#theme(io.jstach.rainbowgum.format.TTLL.ColorTheme%29): which colors. `rainbowgum` (used when not set) is the same coloring as the pattern encoder's default; `spring` follows Spring Boot's console colors (faint time and thread, green, yellow, or red level, cyan logger); `one_dark` and `darcula` use Atom One Dark's (magenta logger) and IntelliJ Darcula's (orange logger) colors in 24 bit color, which needs a terminal with true color support.

Every part also accepts `default`, which restores the default without naming it (for example when a profile overrides a base setting), and `true` or `false` to show or hide it; `theme` accepts `default` only.

Percent encoding (`requestId=42&user=Ada%20Lovelace`) is the default key values format, both for TTLL and for [`KeyValuesFormatterBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/KeyValuesFormatterBuilder.html), because:

- It is reversible: every key and value reads back exactly with [`PercentCodec.decode(CharSequence, java.nio.charset.Charset)`](io.jstach.rainbowgum/io/jstach/rainbowgum/PercentCodec.html#decode(java.lang.CharSequence,java.nio.charset.Charset%29), including separators, newlines, and Unicode, and a key with a null value (written as the key alone) stays distinct from an empty one.
- It always stays on one line and needs no quoting decisions, so no value can break the line or confuse a parser reading it.
- It is a standard (RFC 3986, the URI query form) that every language can decode, and the same encoding Rainbow Gum reads its own URI query properties with.
- It adds no escaping noise when the line ends up in JSON. Many applications write TTLL to the console and let a collector or aggregator turn each line into a JSON document. Percent encoded text has no quotes or backslashes, so it is stored exactly as written, while logfmt or JSON key values would be stored with every quote escaped (`\"Ada Lovelace\"`).

Use `json` or `json5` when a tool downstream reads that format instead.

The same settings work as a URI query (`logging.appender.console.encoder.uri=ttll:///?keyValues=json5`) and programmatically through [`TTLLFormatterBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/TTLLFormatterBuilder.html). See [`TTLL`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/TTLL.html).

### logfmt Formatter <a id="logfmt"></a>

[logfmt](https://brandur.org/logfmt) writes each event as one line of `key=value` pairs, the format of Go's `log/slog` text handler. It is readable in a terminal and parsed directly by Grafana Loki, Vector, and similar tools. It is built into core, so no extra module is needed:

```properties
logging.appenders=myappender
logging.appender.myappender.encoder.uri=logfmt
```

```java
time=2026-10-05T15:04:05.123Z level=INFO logger=com.example.App threadId=1 threadName=main msg="hello world" requestId=42
```

Key values follow the message; one named like a field the encoder writes gets a `keyValues.` prefix (`keyValues.level=debug`). A throwable adds `error` and `stacktrace` with line breaks escaped so every event stays on one line. See [`LogfmtFormatterBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/LogfmtFormatterBuilder.html), which also sets the level format, for example `logging.appender.myappender.encoder.logfmt.levelFormatter=right_pad_level_formatter`, and the thread fields with `thread`, as in the [JSON5 formatter](#core_json).

Values are colored with the same `color` and `theme` properties as the [TTLL formatter](#ttll): by default when the console supports ANSI, with the `rainbowgum` theme. Keys, `msg`, `error`, and `stacktrace` are never colored, and level padding is written after the level's color.

### LTSV Formatter <a id="ltsv"></a>

[LTSV](http://ltsv.org) (Labeled Tab-separated Values) writes each event as one line of tab separated `label:value` fields with logfmt's field names. Values are never quoted, so a line splits on tabs and each field on its first colon. It is built into core:

```properties
logging.appenders=myappender
logging.appender.myappender.encoder.uri=ltsv
```

With the tabs shown as `⇥`:

```java
time:2026-10-05T15:04:05.123Z⇥level:INFO⇥logger:com.example.App⇥threadId:1⇥threadName:main⇥msg:hello world⇥requestId:42
```

Tab, newline, carriage return, and `\` in a value are backslash escaped (`\t`, `\n`, `\r`, `\\`), so every event stays on one line. Key values, the `thread`, `color`, and `theme` properties, and `error` and `stacktrace` work as in the [logfmt formatter](#logfmt), except that with color on, `error` and `stacktrace` take the level's color, since they are on the event's line. See [`LtsvFormatterBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/LtsvFormatterBuilder.html).

The `timestamp`, `level`, and `logger` properties take the same choices as the [TTLL formatter](#ttll)'s, including a DateTimeFormatter pattern for `timestamp`, but by default the time is ISO 8601 and the level is not padded. `none` leaves a field out:

```properties
logging.appender.console.encoder.ltsv.timestamp=ttll
logging.appender.console.encoder.ltsv.level=padded
logging.appender.console.encoder.ltsv.logger=short
logging.appender.console.encoder.ltsv.thread=none
```

```java
time:15:04:05.123⇥level:INFO ⇥logger:App⇥msg:hello world⇥requestId:42
```

`columns` lists fields to write first, in that order and without labels, so they are read by position, from `time`, `level`, `logger`, `thread` and `msg`. The fields not listed follow with their labels, then the key values, `error` and `stacktrace`, which always keep theirs. The output is then no longer LTSV. Every field as a column:

```properties
logging.appender.console.encoder.ltsv.columns=time,level,logger,thread,msg
```

```java
2026-10-05T15:04:05.123Z⇥INFO⇥com.example.App⇥1⇥main⇥hello world⇥requestId:42
```

The [systemd journal](#rolling_journald) records the time itself, and the [`journald` post processor](#post_processors) gives it the level, so a service can leave both out, keep the logger and message as columns, and have the thread and key values labeled on the right:

```properties
logging.appender.console.encoder.uri=ltsv
logging.appender.console.encoder.ltsv.columns=logger,msg
logging.appender.console.encoder.ltsv.timestamp=none
logging.appender.console.encoder.ltsv.level=none
logging.appender.console.encoder.postProcessors=journald
```

```java
<6>com.example.App⇥hello world⇥threadId:1⇥threadName:main⇥requestId:42
```

A terminal has a tab stop every 8 columns, so short fields such as `level:INFO` are followed by wide gaps and a line soon wraps. The Unix `tabs` command sets the terminal's tab stops, and `tabs -2` puts one every 2 columns, so the fields sit close together like words while the log keeps the tabs that tools split on. `tabs -8` sets them back. A pager has its own tab stops, so use `less -x2` there:

```shell
tabs -2
java -jar app.jar
less -x2 app.log
```

### JSON5 Formatter <a id="core_json"></a>

The `json5` encoder writes each event as one line (unless `prettyPrint=full`) holding a JSON5 object, so an application that normally logs TTLL can switch to structured logging, for example while hunting a bug, by flipping one property and without adding a module:

```properties
logging.appender.console.encoder.uri=json5
```

```java
{time:"2026-10-05T15:04:05.123Z",level:"INFO" ,logger:"com.example.App",threadId:"1",threadName:"main",msg:"hello world",requestId:"42"}
```

It writes JSON5 by default, so it is not mistaken for the way to log JSON: like the other text formatters it is mostly for people reading logs, and the [JSON encoders](#json_encoders) are for JSON logging. The `json` encoder writes the same fields as plain JSON. It has its own properties, of which only `keyValues` and `thread` below apply:

```properties
logging.appender.console.encoder.uri=json
logging.appender.console.encoder.json.keyValues=nested
logging.appender.console.encoder.json.thread=name
```

The fields use logfmt's names: `time`, `level`, `logger`, `threadId` and `threadName` (see `thread` below), `msg`, and for a throwable `error` and `stacktrace`. Every value is a string, or `null` for a key value without one. Properties of the encoder:

- [`format`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/Json5FormatterBuilder.html#format(io.jstach.rainbowgum.format.KeyValuesFormatterBuilder.Format%29): `json5` (default), which leaves identifier keys unquoted, or `json` (`{"time":"...","level":"INFO",...}`).
- [`keyValues`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/Json5FormatterBuilder.html#keyValues(io.jstach.rainbowgum.format.KeyValuesPlacement%29): `merged` (default) writes key values alongside the event's fields, the way logfmt and most aggregators expect, and places any key value named like one of those fields in a nested `keyValues` object instead, so nothing is dropped, renamed, or written twice; `nested` always writes them in the `keyValues` object (`{}` when there are none); `none` leaves them out.
- [`thread`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/Json5FormatterBuilder.html#thread(io.jstach.rainbowgum.format.ThreadFields%29): `both` (default) writes `threadId` and `threadName`, since a virtual thread's name is usually empty; `name` writes `thread`; `id` writes `threadId`; `none` leaves the thread out.
- [`prettyPrint`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/Json5FormatterBuilder.html#prettyPrint(io.jstach.rainbowgum.format.Json5PrettyPrint%29): `level_padding` (default) pads after the level's closing quote so the fields after it line up and the value stays the level name: `level:"INFO" ,logger:...`; `spacing` also adds a space after every comma: `level:"INFO" , logger:"com.example.App", threadId:...`; `full` (or `true`) puts each field on its own line, indented one space like the [rainbowgum-json](io.jstach.rainbowgum.json/module-summary.html) encoders' pretty print, so an event is no longer one line; `off` adds no whitespace.
- [`color`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/Json5FormatterBuilder.html#color(io.jstach.rainbowgum.format.TTLL.ColorMode%29) and [`theme`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/Json5FormatterBuilder.html#theme(io.jstach.rainbowgum.format.TTLL.ColorTheme%29): color values the same way the [TTLL formatter](#ttll) does, by default when the console supports ANSI. Keys, `msg`, `error`, and `stacktrace` are never colored.

`prettyPrint`, `color`, and `theme` only apply to JSON5. With `format=json` they are ignored, so the output stays plain JSON. The `json5` and `json` encoders are a convenience, not a replacement for [rainbowgum-json](io.jstach.rainbowgum.json/module-summary.html): they have one fixed set of fields and no particular schema. For production structured logging, especially into a system that expects ECS, GELF, or Logstash fields, use that module's encoders instead. See [`Json5FormatterBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/Json5FormatterBuilder.html) and [`JsonFormatterBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/JsonFormatterBuilder.html).

### JSON Key Values Formatter <a id="json_key_values_formatter"></a>

[`KeyValuesFormatterBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/KeyValuesFormatterBuilder.html) builds a `LogFormatter` that appends key values as JSON or JSON5 text directly to a `StringBuilder`. It requires no JSON library and can be composed with other formatters:

```java
LogFormatter formatter = LogFormatter.builder()
    .message()
    .text(" ")
    .add(new KeyValuesFormatterBuilder()
        .format(KeyValuesFormatterBuilder.Format.JSON5)
        .nullStrategy(LogFormatter.KeyValueNullStrategy.SKIP)
        .build())
    .newline()
    .build();
```

For a message of `hello` and a `requestId` key value of `42`, this writes `hello {requestId:"42"}` followed by a newline.

- The default is JSON, with all keys quoted. JSON5 leaves valid identifier keys unquoted; keys containing spaces, dots, or hyphens remain quoted. All non-null values are strings.
- All keys are written in event order by default. Use `keys(List.of("requestId", "user"))` to select keys and their order.
- The null strategy defaults to `KEEP`, which writes `null`. `EMPTY` writes `""` and `SKIP` omits the key. Missing selected keys follow the same strategy.
- The text includes object braces, including `{}` when no keys are written.

### Pattern Formatter <a id="pattern"></a>

For those coming from Logback or Log4j2 Rainbow Gum has an [optional module](io.jstach.rainbowgum.pattern/module-summary.html) for [Logback style based pattern](https://logback.qos.ch/manual/layouts.html#ClassicPatternLayout) formatters. This allows describing an output format using `String.format` percent style syntax, e.g. `"%-5level %logger - %msg%n"`. Rainbow Gum implements most of the builtin Logback pattern keywords with far less overhead. The builtin keywords are listed in [`PatternRegistry.KeywordKey`](io.jstach.rainbowgum.pattern/io/jstach/rainbowgum/pattern/format/PatternRegistry.KeywordKey.html) and [`PatternRegistry.ColorKey`](io.jstach.rainbowgum.pattern/io/jstach/rainbowgum/pattern/format/PatternRegistry.ColorKey.html). **The pattern module is not part of the aggregate rainbow gum dependency**; add it to use patterns, and while it is present it is the default encoder for console output. Without it the console uses the [TTLL encoder](#ttll), whose default rainbowgum color theme writes the same colors as the pattern module's default pattern.

```xml
<dependency>
    <groupId>io.jstach.rainbowgum</groupId>
    <artifactId>rainbowgum-pattern</artifactId>
    <version>0.17.2</version>
</dependency>
```

> **Note**
>
> The **color** pattern keywords need no further module such as JAnsi. Rainbow Gum detects whether the process is attached to an ANSI capable terminal using only [`System.console()`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/System.html#console(%29) and well known environment variables (`NO_COLOR`, `TERM`; see [`AnsiSupport`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/AnsiSupport.html)), and simply does not emit ANSI escape sequences when it is not. The separate JAnsi module [covered below](#jansi) is no longer generally needed; it is now largely a legacy option for a handful of edge cases.

["logging.global.ansi.mode"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#GLOBAL_ANSI_MODE_PROPERTY) overrides the detection for the whole configuration: `auto` (the default) detects, `on` always emits ANSI escape sequences, and `off` never does and also keeps JAnsi from installing if that module is in use. It is also set with [`LogConfig.Builder.ansiMode(io.jstach.rainbowgum.LogConfig.Globals.AnsiMode)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#ansiMode(io.jstach.rainbowgum.LogConfig.Globals.AnsiMode%29).

`%highlight` colors its content by level. With no options it uses Logback's colors (error bold red, warn red, info blue). As a Rainbow Gum extension it also accepts Log4j2 style `LEVEL=style` options, where a style is a color plus optionally `bold` or `faint`; levels not listed keep their default:

```properties
logging.appender.console.encoder.pattern.pattern=%highlight(%-5level){ERROR=red bold, INFO=blue bold, WARN=red} %msg%n
```

#### Selecting and Configuring the Pattern Encoder <a id="pattern_encoder_config"></a>

The pattern encoder's URI scheme is ["pattern"](io.jstach.rainbowgum.pattern/io/jstach/rainbowgum/pattern/format/PatternEncoder.html#PATTERN_SCHEME). Because it is the default for console output when the module is present, setting a pattern on an appender is often all that is needed:

```properties
logging.appenders=myappender
logging.appender.myappender.encoder.uri=pattern
logging.appender.myappender.encoder.pattern.pattern=[%thread] %-5level %logger{15} - %msg%n
```

To use the pattern encoder only where an encoder names it, so console output that does not name one keeps the plain TTLL encoder, set ["logging.pattern.mode"](io.jstach.rainbowgum.pattern/io/jstach/rainbowgum/pattern/format/PatternConfigurator.html#LOGGING_PATTERN_MODE_PROPERTY) to `explicit`. The default is `console`.

#### Configuring PatternConfig with Properties <a id="pattern_config"></a>

[`PatternConfig`](io.jstach.rainbowgum.pattern/io/jstach/rainbowgum/pattern/format/PatternConfig.html) carries the platform specific settings that keywords need: time zone (for `%d`/`%date`), line separator (for `%n`), whether color keywords output ANSI escape codes, and the start time used by `%r`/`%relative`. The time zone defaults to the system time zone, as in Logback. It is resolved *per encoder name* through ["logging.pattern.config.{name}."](io.jstach.rainbowgum.pattern/io/jstach/rainbowgum/pattern/format/PatternConfig.html#PATTERN_CONFIG_PREFIX), so different appenders can each have their own:

```properties
logging.appender.myappender.encoder.uri=pattern
logging.pattern.config.myappender.zoneId=UTC
logging.pattern.config.myappender.lineSeparator=\n
logging.pattern.config.myappender.ansi=off
```

`ansi` takes the same values as `logging.global.ansi.mode`. The default `auto` follows the global mode, `on` and `off` decide for that encoder, and a global `off` wins over all of them. `%property{key}` is different: it looks up ad-hoc key values that are not tied to a particular encoder, through ["logging.pattern.property."](io.jstach.rainbowgum.pattern/io/jstach/rainbowgum/pattern/format/PatternConfig.html#PATTERN_PROPERY_PREFIX):

```properties
logging.pattern.property.app=myapp
```

With the above, `%property{app}` anywhere in a pattern outputs `myapp`.

#### Custom Keywords and Programmatic Configuration <a id="pattern_extend"></a>

Like Logback you can add your own pattern keywords, and [`PatternConfig`](io.jstach.rainbowgum.pattern/io/jstach/rainbowgum/pattern/format/PatternConfig.html) can instead be set programmatically as a single default shared by every encoder that has no more specific property configuration. Both (with full code examples) are covered in the [rainbowgum-pattern](io.jstach.rainbowgum.pattern/module-summary.html) module javadoc.

#### Automatic Exception Rendering <a id="pattern_exception"></a>

Notice that none of the pattern examples above (e.g. `[%thread] %-5level %logger{15} - %msg%n`) mention an exception keyword at all. As with Logback, this is intentional and safe: if a pattern does not otherwise use `%ex`/`%xEx`/`%rEx` (or their aliases), Rainbow Gum automatically appends a default exception formatter to the end of the compiled pattern, so a logged throwable is never silently dropped just because the pattern forgot to ask for it. `%rEx`/`%rootException` takes the same options as `%xEx` (depth, exclude patterns, packaging data) but prints the root cause first and works back up through each wrapper, captioned `Wrapped by:` instead of `Caused by:` - useful when the underlying failure is buried under several layers of wrapping and you want it to be the first thing you see:

```properties
logging.appender.myappender.encoder.pattern.pattern=%msg%n%rEx
```

To opt out and suppress exception rendering entirely, add `%nopex` (or `%nopexception`) anywhere in the pattern (like the other throwable keywords, its mere presence is enough to disable the automatic append), and it renders nothing itself:

```properties
logging.appender.myappender.encoder.pattern.pattern=%msg%nopex
```

### JAnsi support (largely legacy) <a id="jansi"></a>

Rainbow Gum still has an optional [JAnsi module](io.jstach.rainbowgum.jansi/module-summary.html) for cross platform ANSI output, but it is **essentially deprecated** and should not be needed by most users. It predates [`AnsiSupport`](io.jstach.rainbowgum/io/jstach/rainbowgum/format/AnsiSupport.html), the JDK-native ANSI detection [the pattern module now uses by default](#pattern), and its original reasons for existing have mostly gone away:

- **Windows.** JAnsi's original purpose was translating ANSI escapes into Win32 console calls for the legacy Windows console, which did not understand ANSI at all. Modern Windows terminals (Windows 10+, Windows Terminal) support ANSI/VT sequences natively, so this is largely a non-issue today.
- **Stripping ANSI on piping/redirection.** JAnsi works by wrapping `System.out`/ `System.err` and stripping escape sequences at write time when it decides the destination is not a real terminal, which requires JAnsi to correctly detect that in the first place. `AnsiSupport` instead decides once, using [`System.console()`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/System.html#console(%29), whether to emit ANSI escapes *at all*, which is both simpler and does not depend on a terminal-detection library getting it right. This matters because terminal detection is a genuinely hard problem in practice: for example JLine's terminal detection (used by a number of other tools for the same purpose) is known to not correctly detect piped/redirected output in some cases, emitting escape codes into a pipe it should have recognized as non-interactive.

> **Note**
>
> [Future versions of the JDK may require command line arguments](https://openjdk.org/jeps/8307341) for using jars packaged with native libraries, which JAnsi is. Given that Rainbow Gum favors security we strongly agree with the draft JDK Enhancement Proposal (JEP): this is one more reason `AnsiSupport`'s pure-JDK approach (no native code, no reflection, no separate terminal library) is now the preferred path.

Jansi can be disabled with ["logging.jansi.disable"](io.jstach.rainbowgum.jansi/io/jstach/rainbowgum/jansi/JAnsiConfigurator.html#JANSI_DISABLE) set to `true` or ["logging.global.ansi.mode"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#GLOBAL_ANSI_MODE_PROPERTY) set to `off`.

A further reason to avoid Jansi is that it may *accidentally strip ANSI escape characters for terminals that do support ANSI but Jansi cannot determine they do*. The most notable case of this problem are IDE terminals/consoles particularly [**IntelliJ's**](https://youtrack.jetbrains.com/issue/IDEA-132822).

The module is kept around for the remaining edge cases where its Win32 console translation is still relevant (e.g. genuinely legacy Windows environments), but new users should not need to add it. It only installs JAnsi's console wrapper and no longer provides its own console format: colors come from the pattern encoder or the default encoder, the same as without the module.

## Outputs <a id="outputs"></a>

[`LogOutput`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogOutput.html) do the actual work of outputting an event. Configuring an [appenders output with properties](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#APPENDER_OUTPUT_PROPERTY) looks something like:

```properties
  logging.appenders=myappender
  logging.appender.myappender.output.uri=stdout
```

One caveat with file support output via URI is if you need to output to a file in the current working directory the URI should be prefixed with `./`.

```properties
  logging.appenders=myappender
  # logging.appender.myappender.output.uri=app.log this is wrong.
  logging.appender.myappender.output.uri=./app.log
```

The reason is that Rainbow Gum will think `app.log` is a URI scheme if it is not prefixed. Of course fully qualified file URI are supported as well like: `file:///./app.log`.

For Spring Boot compatibility ["logging.file.name"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#FILE_PROPERTY) is also supported if custom routers and appenders are not configured. Unlike the generic `output` property above, ["logging.file.name"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#FILE_PROPERTY) is **not** subject to the `./` caveat: since it is documented to always be a file path (never a URI scheme reference), Rainbow Gum resolves it as one directly, so both of the following work as expected without needing a `./` prefix:

```properties
logging.file.name=app.log
```

```properties
logging.file.name=logs/app.log
```

An explicit file URI such as `file:///./app.log` is still honored as-is.

Here are some of the supported outputs (not a complete listing):

### Console <a id="console"></a>

`"stdout"` and `"stderr"` are the default outputs, require no additional module, and need no further configuration beyond the URI scheme itself:

```properties
logging.appenders=myapp
logging.appender.myapp.output.uri=stdout
```

```properties
logging.appenders=myapp
logging.appender.myapp.output.uri=stderr
```

With [`cached`](io.jstach.rainbowgum/io/jstach/rainbowgum/output/ConsoleStream.html#CACHED) (the default), console outputs use whatever [`System.out`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/System.html#out) or [`System.err`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/System.html#err) is when the output is created, so rebinding it later with [`System.setOut`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/System.html#setOut(java.io.PrintStream%29) is not seen. To read the stream on every write instead (for example so a test that captures standard out also captures log output), set the [`stream`](io.jstach.rainbowgum/io/jstach/rainbowgum/output/StdOutOutputBuilder.html#stream(io.jstach.rainbowgum.output.ConsoleStream%29) parameter to [`follow`](io.jstach.rainbowgum/io/jstach/rainbowgum/output/ConsoleStream.html#FOLLOW) in the URI or as an output property:

```properties
logging.appenders=myapp
logging.appender.myapp.output.uri=stdout:///?stream=follow
# or equivalently
logging.appender.myapp.output.stdout.stream=follow
```

Do not use [`follow`](io.jstach.rainbowgum/io/jstach/rainbowgum/output/ConsoleStream.html#FOLLOW) if something redirects standard out into logging, since the output would then log to itself. Programmatically, use [`StdOutOutputBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/output/StdOutOutputBuilder.html) or [`StdErrOutputBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/output/StdErrOutputBuilder.html) with [`ConsoleStream`](io.jstach.rainbowgum/io/jstach/rainbowgum/output/ConsoleStream.html).

### File Output <a id="file"></a>

The [rainbowgum-file](io.jstach.rainbowgum.file/module-summary.html) module (not included by default; [rainbowgum-core](io.jstach.rainbowgum/module-summary.html) on its own has no file I/O capability at all) provides plain, non-rolling file output under the "file" URI scheme, [`FileOutputBuilder`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/file/FileOutputBuilder.html):

```properties
logging.appenders=myapp
logging.appender.myapp.output.uri=file:///var/log/app.log
logging.appender.myapp.output.file.append=false
```

Its settings are keys under `logging.appender.{name}.output.file.`, or options on the URI (`file:///var/log/app.log?append=false`). See [`FileOutputBuilder`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/file/FileOutputBuilder.html) for the full list of supported properties (e.g. [`append`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/file/FileOutputBuilder.html#append(java.lang.Boolean%29), [`prudent`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/file/FileOutputBuilder.html#prudent(java.lang.Boolean%29), [`bufferSize`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/file/FileOutputBuilder.html#bufferSize(io.jstach.rainbowgum.file.DataSize%29)) and their defaults. A file in the working directory is written `./logs/app.log` or `file:///./logs/app.log`, and missing parent directories such as `logs` are created.

### JDK Flight Recorder (JFR) <a id="jfr"></a>

The optional [JFR module](io.jstach.rainbowgum.jfr/module-summary.html) (inspired by [JFRLog](https://github.com/mbien/JFRLog)) commits each log event as a JFR event instead of writing bytes anywhere, with one event type per level (`io.jstach.rainbowgum.log.Trace`/`Debug`/`Info`/ `Warn`/`Error`) so each can be independently enabled, thresholded, or given a stack trace setting through a Flight Recorder configuration (`.jfc` file or `-XX:StartFlightRecording`) the same way as any other JFR event, not through Rainbow Gum properties.

```properties
logging.appenders=myappender
logging.appender.myappender.output.uri=jfr:///
```

Leaving `encoder` unset picks up [`JfrLogOutput`](io.jstach.rainbowgum.jfr/io/jstach/rainbowgum/jfr/JfrLogOutput.html)'s own default encoder, which renders the message followed by any key values, e.g. `some message - {key=value}`, or just the message when there are none. There is no timestamp/level/logger prefix, since the JFR event already carries those as separate fields. Set `logging.appender.myappender.encoder.uri` explicitly to override it.

#### Starting A Recording <a id="jfr_starting"></a>

Events sitting in `io.jstach.rainbowgum.log.*` only get recorded somewhere if a Flight Recorder session that enables them is actually running - there are two ways to make that happen.

The usual way is wiring JFR in at the JVM level, which works but has a rough edge: the flags are easy to get wrong, differ across JVM vendors/versions, and are yet another thing to remember to add to a container entrypoint or systemd unit, entirely separate from the rest of the application's logging configuration:

```java
java -XX:StartFlightRecording:filename=recording.jfr,dumponexit=true,settings=profile -jar myapp.jar
```

The simpler alternative, and the one worth reaching for first, needs none of that: give the output's own URI a real file path instead of the bare `jfr:///`. No JVM flags, no `.jfc` file - nothing outside the `logging.appender.*.output.uri` property already being set for any other output:

```properties
logging.appenders=myappender
logging.appender.myappender.output.uri=jfr:///var/log/myapp.jfr
```

This starts and owns a Flight Recorder session for the lifetime of the output, writing directly to that file, with every event type unconditionally enabled - unlike the bare `jfr:///` form, JFR's own per-event filtering does not apply here at all. Whether an event is captured is decided solely by Rainbow Gum's normal level resolver, the same one that already decides whether the output is written to in the first place.

`jfr print --events "io.jstach.rainbowgum.log.*" recording.jfr` then shows the recorded events regardless of which way the recording was started. TRACE and DEBUG defaulting to disabled (too high volume to want on by default) only matters for the bare `jfr:///` form - a URI-started recording enables every level unconditionally; enable them explicitly in a custom `.jfc` settings file if using `-XX:StartFlightRecording` instead.

### JFR Alert Listener <a id="jfr_alerts"></a>

The same module can also commit Rainbow Gum's own [`alerts`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAlerts.html) (an appender failing to write, an async publisher's queue overflowing, and similar problems with the logging system itself, not application log lines) as JFR events, opt-in via:

```properties
logging.jfr.alerts.mode=on
```

Disabled by default: unlike the output above, which stays inert until an appender explicitly selects the `jfr` URI scheme, this listener has no such per-appender opt-in moment - once enabled it commits every alert as a JFR event for the life of the process.

Alerts use their own, separate JFR event types (`io.jstach.rainbowgum.alert.AlertTrace`/`AlertDebug`/ `AlertInfo`/`AlertWarn`/`AlertError`) in their own `Alert` category, rather than reusing the event types above, which are in the `Log` category. Select them by namespace with `jfr print --events "io.jstach.rainbowgum.alert.*"` or by category with `jfr print --categories Alert`. The `Alert` prefix keeps simple names distinct too: `jfr print --events Error` returns only application errors, never Rainbow Gum's own alerts.

### Rolling Files <a id="rolling"></a>

#### Built-in Rolling <a id="rolling_builtin"></a>

The same [rainbowgum-file](io.jstach.rainbowgum.file/module-summary.html) module additionally provides a deliberately basic, size based rolling file output under the "rolling" URI scheme, [`RollingFileOutput`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/rolling/RollingFileOutput.html):

```properties
logging.appenders=myapp
logging.appender.myapp.output.uri=rolling:///var/log/app.log?maxFileSize=10MB&maxHistory=7
```

As with file URIs, `rolling:///./logs/app.log` is relative to the working directory. See [`RollingFileOutputBuilder`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/rolling/RollingFileOutputBuilder.html) for the full list of properties ([`maxFileSize`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/rolling/RollingFileOutputBuilder.html#maxFileSize(io.jstach.rainbowgum.file.DataSize%29), [`maxHistory`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/rolling/RollingFileOutputBuilder.html#maxHistory(java.lang.Integer%29), [`totalSizeCap`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/rolling/RollingFileOutputBuilder.html#totalSizeCap(io.jstach.rainbowgum.file.DataSize%29), [`cleanHistoryOnStart`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/rolling/RollingFileOutputBuilder.html#cleanHistoryOnStart(java.lang.Boolean%29), [`fileNamePattern`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/rolling/RollingFileOutputBuilder.html#fileNamePattern(java.lang.String%29)) and their defaults. They work equally well as query parameters above or as `logging.appender.{name}.output.rolling.*` properties.

`maxFileSize` and `totalSizeCap` take a number with an optional unit, for example `10MB`, `512k`, or `1.5 GiB`. Units are case insensitive and always powers of 1024 (`MB` is 1024<sup>2</sup> bytes, never 1000<sup>2</sup>), and a number without a unit is bytes. Every size Logback accepts means the same thing here. See [`DataSize`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/file/DataSize.html) for the full format.

**This is deliberately basic: just enough to keep a small/desktop app's disk from filling up, not a substitute for a real log rotation/aggregation policy.** There is no calendar/date based rotation, no compression on a schedule independent of rotation, and no coordination across multiple processes writing the same file. If you need any of that, use the external-tool approach below instead (typically [logrotate](https://manpages.debian.org/latest/logrotate/logrotate.8.en.html)), or for a systemd service let [the journal](#rolling_journald) handle it. It remains the recommended approach for anything beyond preventing a disk from filling up, and does not depend on the [rainbowgum-file](io.jstach.rainbowgum.file/module-summary.html) module at all.

#### External Tool Support (logrotate) <a id="rolling_external"></a>

How this typically works:

1. External program moves the current log file. Rainbow Gum will continue to log to the same file but the file name is effectively changed.
2. Signals to the Java process with Rainbow Gum to reopen the files. This signal is usually done via HTTP or TCP socket since Java does not support Unix signals.
3. The external program then typically compresses, delete or send the log files elsewhere.

The critical thing that is happening is that Rainbow Gum closes the moved log file and then reopens the original named log file thus releasing the moved log file descriptor allowing the external program to process it without dropped log events, contention or corruption.

(*The other method of rotating files without doing a move and reopen is called "copy truncate" but has the potential of losing events. This method avoids that problem.* )

Unfortunately Rainbow Gum does not offer a way to receive the external signal as this can vary greatly across applications. The following is an example of reopening outputs using HTTP for signaling.

```java
/*
 * This method could be bound to an internal HTTP route say /log/rotate such that curl
 * http://localhost:8080/log/rotate will block and wait till all the applicable
 * outputs have reopened.
 */
@RequestMapping("/log/rotate")
@ResponseBody
public String someInternalHttpRequestHandler() {
	var gum = RainbowGum.getOrNull();
	if (gum != null) {
		List<LogEvent> errors = gum.config() //
			.outputRegistry() //
			.reopen(); // Here is where we siginal to reopen outputs that support
						// reopening. Anything that failed is also reported to the
						// alert system (see LogConfig#alerts()) - errors here is
						// just that same information handed back to the caller.
		return errors.isEmpty() ? "ok" : errors.toString();
	}
	return "";
}
```

Let us assume the above code is bound to `http://localhost:8080/log/rotate` and we have configured our logging like

```properties
  logging.appenders=myappender
  logging.appender.myappender.output.uri=/var/log/app.log
```

We might have a logrotate script that looks like:

```java
/var/log/app.log
{
  rotate 4
  weekly
  missingok
  notifempty
  compress
  delaycompress
  # we only need one call to reopen all files
  sharedscripts
  # in most cases it is best for rainbowgum recreate the file which wil happen after the postrotate
  nocreate
  postrotate
    /usr/bin/curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/log/rotate | {
      read status
      if [ "$status" -ne 200 ]; then
          logger "logrotate: Error hitting endpoint, received HTTP status $status"
      fi
    }
  endscript
}
```

#### systemd Journal <a id="rolling_journald"></a>

An application run as a systemd service can skip rolling files altogether. systemd sends the service's standard out to its journal by default, and the journal handles rotation, retention and size limits (for example `SystemMaxUse` in `journald.conf`), with `journalctl` to read it. Log to the console and add the [`journald` post processor](#post_processors) so each line carries the event's priority, with `crlf` first so a multi-line event such as a stack trace stays one journal entry:

```properties
logging.appender.console.encoder.postProcessors=crlf,journald
```

This suits a service without log aggregation such as Fluent Bit, and an aggregator can still be added later reading from the journal.

### OpenTelemetry <a id="otlp"></a>

The optional [rainbowgum-opentelemetry](io.jstach.rainbowgum.opentelemetry/module-summary.html) module adds the current OpenTelemetry span's `traceId` and `spanId` to log events through a [`key values contributor`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEventFactory.KeyValuesContributor.html). It works with any output or encoder and can be used independently of [rainbowgum-otlp](io.jstach.rainbowgum.otlp/module-summary.html).

```xml
<dependency>
    <groupId>io.jstach.rainbowgum</groupId>
    <artifactId>rainbowgum-opentelemetry</artifactId>
    <version>0.17.2</version>
    <scope>runtime</scope>
</dependency>
```

Adding the module enables the contributor. IDs are captured from a valid current span when the event is created on the logging thread, so they remain available during asynchronous publishing. The OpenTelemetry context can come from application code, a framework, the SDK, or a Java agent; an agent is not required. If there is no valid current span, the contributor adds no key values.

#### OTLP/HTTP Output <a id="otlp_output"></a>

The optional [rainbowgum-otlp](io.jstach.rainbowgum.otlp/module-summary.html) module exports logs in the OpenTelemetry Protocol without the OpenTelemetry SDK or any protobuf library. Its only dependencies are Rainbow Gum itself (core and [rainbowgum-json](io.jstach.rainbowgum.json/module-summary.html)) and the JDK's own HTTP client. [`OtlpOutput`](io.jstach.rainbowgum.otlp/io/jstach/rainbowgum/otlp/OtlpOutput.html) posts batches to an OTLP/HTTP endpoint (`/v1/logs`) as protobuf (the OTLP default) or JSON. Pair it with the asynchronous publisher so a log call never waits on the network:

```properties
logging.appenders=otel
logging.appender.otel.output.uri=otlp:///
logging.appender.otel.output.otlp.endpoint=http://collector:4318/v1/logs
logging.appender.otel.output.otlp.serviceName=orders
logging.route.default.publisher.uri=async
```

Other properties are `protocol` (`http/protobuf` or `http/json`), `headers`, `compression` (`gzip`), `timeout` (milliseconds), `maxBatchSize`, `resourceAttributes`, `traceIdKey`/`spanIdKey`, and `keyValuesIncluded`/`keyValuesExcluded`. `headers` usually holds credentials, so it is sensitive: its values are never shown, and it cannot be set in the query of the `otlp` URI. Set it as its own property instead, preferably from your application's configuration system or `OTEL_EXPORTER_OTLP_HEADERS` (see below) rather than a file:

```properties
logging.appender.otel.output.otlp.headers.keys=Authorization
logging.appender.otel.output.otlp.headers.Authorization=Bearer your-token
```

Retryable responses (429, 502, 503, 504) and network errors are retried with randomized backoff. The timeout bounds the whole export, including retries and response-body reads. A batch that still fails is dropped and reported as an [alert](#alerts) and the `otlp.records.failed` [metric](#metrics).

**The standard `OTEL_*` environment variables are not read unless you opt in**, since reading the process environment is not something Rainbow Gum does by default:

```properties
logging.appender.otel.output.otlp.environmentVariables=on
```

With that set, `OTEL_SERVICE_NAME`, `OTEL_RESOURCE_ATTRIBUTES`, and the `OTEL_EXPORTER_OTLP_*` (and `OTEL_EXPORTER_OTLP_LOGS_*`) endpoint, protocol, headers, compression, and timeout variables fill in anything not set by a property.

#### OTLP/JSON Encoder <a id="otlp_encoder"></a>

[`OtlpJsonEncoder`](io.jstach.rainbowgum.otlp/io/jstach/rainbowgum/otlp/OtlpJsonEncoder.html) writes each event as one line of OTLP/JSON, the OpenTelemetry file format. Use it with any output, for example standard out in a container, and let the OpenTelemetry Collector read it with its `otlpjsonfile` receiver or its `filelog` receiver and `otlpjson` connector:

```properties
logging.appender.console.encoder.uri=otlp:///
logging.appender.console.encoder.otlp.serviceName=orders
```

The OTLP/HTTP output and OTLP/JSON encoder carry the same record content: the formatted message as the body, the logger name as the instrumentation scope, `thread.name`, `thread.id`, other key values as attributes, and `exception.*` attributes for a throwable. When [caller info](#caller_info) is enabled the record also carries `code.function.name`, `code.file.path`, and `code.line.number`. Event thread, caller, and exception attributes take precedence when context contains the same names. Key values named `traceId` and `spanId` become the record's trace context when they are valid W3C ids. These can come from the OpenTelemetry contributor above or from Micrometer Tracing's MDC integration. A key value named `otel.event.name` becomes the record's event name, as it does with the OpenTelemetry Logback and Log4j appenders.

Every key value (MDC, SLF4J key value pairs, and contributors alike) becomes an attribute by default. `keyValuesIncluded` and `keyValuesExcluded` select which ones with case sensitive globs (`*` matches any characters, `?` one character); an excluded key is never sent:

```properties
logging.appender.otel.output.otlp.keyValuesIncluded=request*,user.id
logging.appender.otel.output.otlp.keyValuesExcluded=*.password,*.token
```

## Filtering <a id="filter"></a>

Like logback Rainbow Gum provides two types of filtering through functional composition:

1. [router based filtering](io.jstach.rainbowgum/io/jstach/rainbowgum/LogRouter.Router.Filter.html), similar to logbacks normal filters.
2. [SLF4J based filtering](io.jstach.rainbowgum.slf4j/io/jstach/rainbowgum/slf4j/spi/LoggerDecoratorService.html), similar to [logback Turbo Filters](https://logback.qos.ch/manual/filters.html#TurboFilter)

### Event based Filtering <a id="router_filter"></a>

A route's events can be dropped or changed by [filters](io.jstach.rainbowgum/io/jstach/rainbowgum/LogRouter.Router.Filter.html) before they reach its publisher. Filters are registered by name, usually from a [configurator](io.jstach.rainbowgum/io/jstach/rainbowgum/spi/RainbowGumServiceProvider.Configurator.html), and selected with the route's `filters` property. They run in the order listed:

```properties
logging.route.default.filters=quietDependency
```

A filter returns the event to keep it, `null` to drop it, or a different event such as one at another level from [`LogEvent.withLevel(io.jstach.rainbowgum.LogEvent, java.lang.System.Logger.Level)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEvent.html#withLevel(io.jstach.rainbowgum.LogEvent,java.lang.System.Logger.Level%29) or with a masked message from [`LogEvent.rewrite(io.jstach.rainbowgum.LogEvent, io.jstach.rainbowgum.LogEvent.Rewriter)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEvent.html#rewrite(io.jstach.rainbowgum.LogEvent,io.jstach.rainbowgum.LogEvent.Rewriter%29). A configurator that registers a filter moving a noisy dependency's warnings down to info:

```java
public class RouteFilterExample implements Configurator {

	@Override
	public boolean configure(LogConfig config, Pass pass) {
		Filter.register(config.serviceRegistry(), "quietDependency", (routeName, c) -> event -> {
			if (event.loggerName().startsWith("com.noisy.") && event.level() == Level.WARNING) {
				/*
				 * Dropped if the route does not enable INFO for the logger.
				 */
				return LogEvent.withLevel(event, Level.INFO);
			}
			return event;
		});
		return true;
	}

}
```

These filters are built in and are configured with properties that start with `logging.route.{name}.filter.{filter}.`:

- `throttle` limits how many events are kept per second ([`ThrottleFilterBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/filter/ThrottleFilterBuilder.html)).
- `dedupe` drops repeats of the same message ([`DedupeFilterBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/filter/DedupeFilterBuilder.html)).
- `remap` moves events from one level to another ([`RemapFilterBuilder`](io.jstach.rainbowgum/io/jstach/rainbowgum/filter/RemapFilterBuilder.html)).

For example to keep a blocking console route from slowing the application down when a burst of warnings arrives, while an async file route still gets every event:

```properties
logging.routes=console,file
logging.route.console.appenders=console
logging.route.console.filters=throttle
logging.route.console.filter.throttle.rate=20
logging.route.file.appenders=file
logging.route.file.publisher.uri=async
logging.file.name=app.log
```

Filters can also be added in code with [`LogRouter.Router.Builder.filter(io.jstach.rainbowgum.LogRouter.Router.Filter)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogRouter.Router.Builder.html#filter(io.jstach.rainbowgum.LogRouter.Router.Filter%29):

```java
RainbowGum.builder(config) //
	.route(rb -> {
		rb.filter(e -> {
			/*
			 * We only log DEBUG level events.
			 */
			return switch (e.level()) {
				case DEBUG -> e;
				default -> null;
			};
		});
		/*
		 * If we do not set the level correctly the router will never get the
		 * event regardless of the logic of the above filtering function.
		 */
		rb.level(Level.DEBUG);
	});
```

*Event based filtering is still based on the invariants of level resolvers not changing (unless they are configured to be dynamic) so not all events are delivered if the level resolved does not allow it!* A filter only sees events the route enables, and an event moved to another level is dropped if the route does not enable that level for its logger. A work around is to adjust the levels of the router so that it does get all events desired and is why filtering is associated with routing. **Unfortunately this can be inefficient as the event always has to be created** so if performance matters consider using [SLF4J based filtering](#slf4j_filter).

### SLF4J based filtering <a id="slf4j_filter"></a>

[SLF4J based filtering](io.jstach.rainbowgum.slf4j/io/jstach/rainbowgum/slf4j/spi/LoggerDecoratorService.html) is not simple filtering but rather decorating of the SLF4J loggers somewhat akin to Servlet filtering. Rainbow Gum hands off its generated SLF4J logger to you and you can decorate or even disregard it and provide your own implementation. This is extremely powerful and efficient but requires more work. There is not really an analog in Logback or Log4j but as usual *with great power comes great responsibility*!

These filters are usually loaded with the ServiceLoader so manually using the Rainbow Gum builder is not required like router based filtering.

Do not implement the decorated [`Logger`](https://www.slf4j.org/api/org/slf4j/Logger.html) by extending [`AbstractLogger`](https://www.slf4j.org/api/org/slf4j/helpers/AbstractLogger.html) directly: getting SLF4J caller-info depth right means depending on that class's internal dispatch shape, which is an unversioned implementation detail and easy to get subtly wrong. Extend [AbstractFilteringLogger](io.jstach.rainbowgum.slf4j/io/jstach/rainbowgum/slf4j/spi/AbstractFilteringLogger.html) instead, which owns and tests its own depth accounting. A decorator that samples DEBUG level events and surfaces any [`Marker`](https://www.slf4j.org/api/org/slf4j/Marker.html) as a key value (there is no built-in `Marker` support otherwise):

```java
public class DecoratorExample extends LoggerDecoratorService {

	@Override
	public String name() {
		return "sampling";
	}

	@Override
	public Logger decorate(RainbowGum rainbowGum, DepthAwareLogger previousLogger, int depth) {
		return new SamplingLogger(previousLogger);
	}

	static class SamplingLogger extends AbstractFilteringLogger {

		private final AtomicInteger debugCount = new AtomicInteger();

		SamplingLogger(DepthAwareLogger delegate) {
			super(delegate);
		}

		@Override
		protected boolean isEnabled(Level level, @Nullable Marker marker) {
			// Cheap pre-check: keep only every 10th DEBUG event, everything else
			// passes through unchanged. This runs before any LoggingEventBuilder
			// is built.
			if (level != Level.DEBUG) {
				return true;
			}
			return debugCount.incrementAndGet() % 10 == 0;
		}

		@Override
		@SuppressWarnings("CheckReturnValue")
		protected boolean decorate(LoggingEventBuilder builder, @Nullable Marker marker) {
			if (marker != null) {
				// Rainbow Gum core has no built-in Marker support (it is not stored
				// on the event), so surface it as a key value instead.
				builder.addKeyValue("marker", marker.toString());
			}
			return true;
		}

	}

}
```

`@Nullable` above is `org.jspecify.annotations.Nullable` from `org.jspecify:jspecify`.

## Alerts, Metrics, and Reporting <a id="alerts_metrics"></a>

Rainbow Gum's own internal health (as opposed to the application events flowing through the [`Router`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogRouter.html)) is exposed through two small, separate [`LogConfig`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html) accessors: [`LogConfig.alerts()`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html#alerts(%29) and [`LogConfig.metrics()`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html#metrics(%29). They are deliberately two different types rather than one combined API. An appender failing to write is a discrete event worth recording with a message (and possibly a throwable), while "how many times has this happened" is much cheaper to just keep as a running number. Each is meant to be independently replaceable later (a future Micrometer backed `LogMetrics`, say, without needing to also replace how alerts are recorded). A third piece, [Reporting](#reporting), ties both of these together with the wired component tree itself into one human (or agent) readable diagnostic snapshot.

### Alerts <a id="alerts"></a>

[`LogAlerts`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAlerts.html) records problems with the logging system itself (an appender failing to write, or an async publisher's queue overflowing) rather than application logging. Because logging itself may be broken these are not routed back through the normal Router but are instead kept in a small in memory ring buffer ([`LogAlerts.dump()`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAlerts.html#dump(%29) and [`LogAlerts.stats()`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAlerts.html#stats(%29)) as well as immediately reported (currently to stderr).

Set `-Dlogging.debug=ERROR` to print the failure and collected alerts if building [`LogConfig`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html) fails. Set `-Dlogging.debug=INFO` to also print the collected alerts after every successful config build. Set `-Dlogging.debug=ALL` to additionally print the [`LogReporter`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogReporter.html) report after Rainbow Gum starts its logging components. Set `-Dlogging.debug=HELP` to do everything `ALL` does and also report misspelled property keys and fail startup on warnings; see [Troubleshooting](#troubleshooting). These dumps include alerts recorded before properties were loaded and do not notify alert listeners. The switch is read before property providers run, so it cannot be set in `logging.properties`. `OFF` is the default; `true` and `false` are aliases for `ALL` and `OFF`, respectively. The [`builder option`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#debug(io.jstach.rainbowgum.LogConfig.DebugModeType%29) sets a fallback mode; the system property takes precedence.

You can also subscribe to alerts as they happen with [`LogAlerts.addListener(io.jstach.rainbowgum.LogAlerts.Listener)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAlerts.html#addListener(io.jstach.rainbowgum.LogAlerts.Listener%29), useful for bridging alerts to whatever alerting/paging system an application already has:

```java
/*
 * Forwards every alert to your own alerting/paging system as it happens, in addition
 * to it still being recorded in the ring buffer.
 */
public AutoCloseable subscribeToAlerts(LogConfig config) {
	return config.alerts().addListener(event -> sendToPagingSystem(event.message()));
}
```

### Metrics <a id="metrics"></a>

[`LogMetrics`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html) is for the cheap, high frequency counters that would be wasteful to record as discrete alert events: counters like ["events.dropped"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html#EVENTS_DROPPED_METRIC) (an appender dropping events on reentry, see [Appender Reentry Protection](#appender_reentry)) and ["buffer.trimmed"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html#BUFFER_TRIMMED_METRIC) (a reused encoder buffer growing past its configured max size and having to shrink itself back down) are both incremented this way rather than as alerts. Every alert also bumps a metrics counter named after the alert's logger name, so counts stay available even once older alerts have been evicted from the ring buffer.

[`LogMetrics.errorCounter(String, long)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html#errorCounter(java.lang.String,long%29) and [`LogMetrics.warnCounter(String, long)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html#warnCounter(java.lang.String,long%29) increment a named counter; [`LogMetrics.snapshot()`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html#snapshot(%29) returns a snapshot of every named value recorded so far. Counters increase over time; a downstream metrics system computes their rate of change.

For values that can rise and fall, retain a handle from [`LogMetrics.gauge(String, java.lang.System.Logger.Level)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html#gauge(java.lang.String,java.lang.System.Logger.Level%29) and call its `increment` and `decrement` methods. Updates go directly to the retained value without a name lookup. Levels below `INFO` and `OFF` return a no-op handle without registering a metric. The blocking async publisher uses ["events.queued"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html#EVENTS_QUEUED_METRIC) at `INFO` to count events waiting in its queues across all publishers sharing the config. An event stops being counted when removed for processing. Snapshots are approximate during concurrent queue activity.

The fixed, well known set of metrics Rainbow Gum itself records is enumerable through [`LogMetrics.StandardMetric`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.StandardMetric.html), useful for something wanting to bind every standard metric to an external system without hand listing each name/level pair. [`LogMetrics.StandardMetric.isGauge()`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.StandardMetric.html#isGauge(%29) distinguishes gauges from counters:

```java
/*
 * Binds every well known metric (see LogMetrics.StandardMetric) to your own metrics
 * system without hand listing each name/level pair - a future new StandardMetric
 * constant is picked up automatically.
 */
public void reportMetrics(LogConfig config) {
	List<LogMetrics.Metric> snapshot = config.metrics().snapshot();
	for (var metric : LogMetrics.StandardMetric.values()) {
		long value = snapshot.stream()
			.filter(c -> c.name().equals(metric.metricName()) && c.level() == metric.level())
			.mapToLong(LogMetrics.Metric::value)
			.findFirst()
			.orElse(0);
		reportToMetricsSystem(metric.metricName(), value);
	}
}
```

For a Spring Boot 4 application, these `StandardMetric` values, and the [diagnostic report](#reporting) below, are both surfaced through Spring Boot's own `/actuator` endpoints: see [Actuator](#spring_boot_actuator) under [Spring Boot](#spring_boot).

### Reporting <a id="reporting"></a>

[`LogReporter`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogReporter.html), from [`LogConfig.reporter()`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html#reporter(%29), renders a plain text diagnostic report of a config and the [`RainbowGum`](io.jstach.rainbowgum/io/jstach/rainbowgum/RainbowGum.html) built from it: the wired component tree itself (which concrete appender, encoder, and output actually got selected for each route, not just what was configured), plus [alerts](#alerts) and [metrics](#metrics) above, all in one place. It is meant to be read by a human, or an agent, while setting things up or debugging an incident, not parsed by anything expecting a stable schema. The rendered text carries no compatibility guarantee and may change between any two releases, including patch releases.

[`LogReporter.Options`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogReporter.Options.html) controls which [`sections`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogReporter.Section.html) are printed (`VERSION`, `COMPONENTS`, `METRICS`, `ALERTS`, `LOGGERS`, `FACADES`, `READ_PROPERTIES`). `LOGGERS` lists the logger names the logging facades have created, each with its resolved level unless [`loggerLevels(false)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogReporter.Options.Builder.html#loggerLevels(boolean%29) is set, `FACADES` lists which facades (SLF4J, JUL, and so on) have actually created loggers, and `READ_PROPERTIES` lists every property key that was read, set or not, see [Troubleshooting](#troubleshooting). The default is just `VERSION` and `COMPONENTS`: the other sections are usually more useful pulled independently the way the sections above already show, so a report only includes them if asked.

```java
/*
 * A full diagnostic report of what actually got wired up: version, the component tree
 * (routers, publishers, appenders, encoders, outputs), metrics, and recent alerts.
 * Cheap to build on demand - print it on an unhandled exception, expose it from an
 * admin endpoint, or just log it once at startup.
 */
public String diagnosticReport(RainbowGum gum) {
	var options = LogReporter.Options.builder()
		.sections(EnumSet.of(Section.VERSION, Section.COMPONENTS, Section.METRICS, Section.ALERTS))
		.build();
	return gum.config().reporter().report(options);
}
```

`COMPONENTS` also lists properties worth seeing in every report, such as `logging.change.mode`, with their current values. Rather than a fixed list, the component that reads such a property adds its key with [`LogReporter.addProperty(Class, String)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogReporter.html#addProperty(java.lang.Class,java.lang.String%29), so a module's own switches (for example `logging.jul.disable`) appear only when that module is in use. Each key shows the packages that read it.

Since alerts are just [`LogEvent`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEvent.html)s like any other, [`LogReporter.Options.Builder.alertFormatter(io.jstach.rainbowgum.LogFormatter)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogReporter.Options.Builder.html#alertFormatter(io.jstach.rainbowgum.LogFormatter%29) lets you swap in a different [`LogFormatter`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogFormatter.html) for how each one is rendered, for example to leave the (otherwise non-deterministic) timestamp out of a report you intend to golden-string test.

A component that wants to contribute its own description to a report instead of just its concrete class name (a custom [`LogOutput`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogOutput.html) or [`LogEncoder`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEncoder.html), say) can opt in by implementing [`LogReporter.Reportable`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogReporter.Reportable.html). This is entirely optional and has no effect on anything except the rendered report.

## Example Configuration <a id="example_configuration"></a>

Everything above introduced routes, level resolvers, publishers, appenders, encoders, and outputs one at a time. This section puts them together into one **non-trivial** configuration, first as properties and then the equivalent using builders, so the full shape of a realistic setup is visible in one place rather than spread across many small snippets.

Assume a hypothetical service `com.mycompany.orders` that wants:

- A human readable, synchronous console appender for local development.
- A structured (JSON) file appender for log aggregation, using an async publisher so encoding and file IO do not block request threads.
- A separate `errors` only file, independent of the two routes above, following the [multiple routes pattern](#Additivity) discussed earlier.
- Noisy third party packages (`org.apache.http`, `io.netty`, `com.zaxxer.hikari`) turned down to `WARN` everywhere via a [level group](#level_groups).

### Properties <a id="example_configuration_properties"></a>

```properties
logging.level=INFO
logging.level.com.mycompany.orders=DEBUG
logging.groups=noisy
logging.group.noisy=org.apache.http,io.netty,com.zaxxer.hikari
logging.level.noisy=WARN

logging.routes=console,structured,errors

logging.route.console.appenders=console
logging.route.console.level=INFO
logging.route.console.level.noisy=WARN

logging.route.structured.appenders=jsonfile
logging.route.structured.publisher.uri=async
logging.route.structured.publisher.async.bufferSize=2048
logging.route.structured.level=DEBUG
logging.route.structured.level.noisy=WARN

logging.route.errors.appenders=errorfile
logging.route.errors.level=ERROR

logging.appender.console.output.uri=stdout
logging.appender.console.encoder.uri=pattern

logging.appender.jsonfile.output.uri=./logs/orders.json.log
logging.appender.jsonfile.encoder.uri=gelf
logging.appender.jsonfile.type=reuse_buffer

logging.appender.errorfile.output.uri=./logs/orders-error.log?bufferSize=10000
logging.appender.errorfile.encoder.uri=pattern

logging.appender.console.encoder.pattern.pattern=[%thread] %-5level %logger{36} - %msg%n

logging.appender.jsonfile.encoder.gelf.host=orders-service
logging.appender.jsonfile.encoder.gelf.prettyPrint=false

logging.appender.errorfile.encoder.pattern.pattern=%d{ISO8601} [%thread] %-5level %logger{36} - %msg%n%ex
```

Four things worth calling out, all confirmed by actually running the above (not just written by hand):

**A route's own levels shadow the global ones.** The `console` and `structured` routes each set a root level, so the global `logging.level.noisy=WARN` alone would not reach them: their own `INFO` and `DEBUG` would win for the noisy packages too. That is why each of those routes repeats the group level as `logging.route.<route>.level.noisy=WARN`. The `errors` route needs no override because its `ERROR` threshold is already stricter.

**Encoder and output configuration lives under the appender.** The `console` appender's encoder is picked by `logging.appender.console.encoder.uri` and configured by the `logging.appender.console.encoder.pattern.*` keys, named after the type `uri` picks, so everything about one appender sits together. The same is true for `jsonfile` and `errorfile`. Switching `encoder.uri` to another type leaves the old type's keys unread rather than misread.

**A route level threshold does act as a hard ceiling.** As covered in [Route Level Priority](#route_level_priority), a route's own level configuration is checked first and takes priority over the global resolver for any logger name the route has an opinion about, regardless of whether the global resolver has a more specific prefix match for that name. That is why the bare `logging.route.errors.level=ERROR` above is enough on its own: even though the global `logging.level.com.mycompany.orders=DEBUG` override applies everywhere else, the `errors` route's own `ERROR` threshold wins for that logger too, with no need for a separate `logging.route.errors.level.com.mycompany.orders` override to restate it.

**A property value that is itself a URI can carry its own query parameters**, as an alternative to separate `logging.appender.{name}.output.{scheme}.{param}` properties. `logging.appender.errorfile.output.uri` above is set to `./logs/orders-error.log?bufferSize=10000` rather than a bare path: the part before `?` is still resolved as the file path exactly as with a bare path, and everything after `?` is parsed the same way a query string would be and made available as properties scoped to that output: here, `bufferSize`, equivalent to also having written `logging.appender.errorfile.output.file.bufferSize=10000` on its own line. This works for a relative, scheme-less path just as well as it does for an explicit `file://` URI; which style to use is purely a matter of preference for how compact versus explicit the properties file should read.

### Builder <a id="example_configuration_builder"></a>

The same configuration (minus the JSON encoder, see the note below) using builders:

```java
RainbowGum.builder(config) //
	.route("console", r -> {
		r.level(Level.INFO);
		r.level(Level.WARNING, "org.apache.http");
		r.level(Level.WARNING, "io.netty");
		r.level(Level.WARNING, "com.zaxxer.hikari");
		r.appender("console", a -> {
			a.output(LogOutput.ofStandardOut());
			a.encoder(new PatternEncoderBuilder("console").pattern("[%thread] %-5level %logger{36} - %msg%n")
				.fromProperties(config.properties())
				.build());
		});
	}) //
	.route("structured", r -> {
		r.level(Level.DEBUG, "com.mycompany.orders");
		r.level(Level.WARNING, "org.apache.http");
		r.level(Level.WARNING, "io.netty");
		r.level(Level.WARNING, "com.zaxxer.hikari");
		r.publisher(PublisherFactory.async().bufferSize(2048).build());
		r.appender("detailfile", a -> {
			/*
			 * A URI-scheme based encoder like the JSON module's "gelf" is
			 * resolved through the service loader, which is why it is comfortable
			 * to reference from properties (see the properties example above)
			 * without the aggregate rainbowgum module needing to require the JSON
			 * module at compile time. Referencing an optional module's encoder
			 * class directly the way this builder is written would require adding
			 * that module as an explicit dependency.
			 */
			a.output(new FileOutputBuilder("detailfile").fileName("./logs/orders-detail.log").build());
			a.encoder(new PatternEncoderBuilder("detailfile")
				.pattern("%d{ISO8601} [%thread] %-5level %logger{50} - %msg%n")
				.fromProperties(config.properties())
				.build());
			a.appenderType(AppenderType.REUSE_BUFFER);
		});
	}) //
	.route("errors", r -> {
		r.level(Level.ERROR);
		r.appender("errorfile", a -> {
			// Appenders flush after every event by default (see
			// AppenderFlag#DISABLE_IMMEDIATE_FLUSH), so no flag is needed
			// here to get synchronous, unbuffered error writes.
			a.output(new FileOutputBuilder("errorfile").fileName("./logs/orders-error.log").build());
			a.encoder(new PatternEncoderBuilder("errorfile")
				.pattern("%d{ISO8601} [%thread] %-5level %logger{36} - %msg%n%ex")
				.fromProperties(config.properties())
				.build());
		});
	});
```

Notice the `structured` route above uses a plain text pattern encoder instead of the JSON module's `gelf` encoder used in the properties version. A URI scheme based encoder like `gelf` is resolved through the service loader at runtime, which is precisely why it is comfortable to reference from properties without the aggregate [rainbowgum](io.jstach.rainbowgum.bundle/module-summary.html) module needing to `requires` the JSON module at compile time. Referencing [`GelfEncoder`](io.jstach.rainbowgum.json/io/jstach/rainbowgum/json/encoder/GelfEncoder.html) directly from a builder the way the rest of this example is written would require adding [rainbowgum-json](io.jstach.rainbowgum.json/module-summary.html) as an explicit compile dependency of whatever module the builder code lives in, illustrating a real trade-off between the two configuration styles rather than only a stylistic one.

## Installation <a id="installation"></a>

For most simply including the dependency [rainbowgum](io.jstach.rainbowgum.bundle/module-summary.html) is enough. That dependency transitively pulls in core, the SLF4J binding, and the [`System.Logger`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/System.Logger.html) and `java.util.logging` integrations. Core provides the `stdout` and `stderr` outputs and the `ttll`, `logfmt`, `ltsv`, `json5` and `json` encoders. Other URI schemes need their module added as a dependency:

**Modules for URI schemes not in core**

| Scheme | Kind | Module |
|---|---|---|
| [`pattern`](io.jstach.rainbowgum.pattern/module-summary.html) | encoder | [rainbowgum-pattern](io.jstach.rainbowgum.pattern/module-summary.html) |
| [`gelf`](io.jstach.rainbowgum.json/module-summary.html), [`ecs`](io.jstach.rainbowgum.json/module-summary.html), [`logstash`](io.jstach.rainbowgum.json/module-summary.html), [`logback`](io.jstach.rainbowgum.json/module-summary.html) | encoder | [rainbowgum-json](io.jstach.rainbowgum.json/module-summary.html) |
| [`file`](io.jstach.rainbowgum.file/module-summary.html), [`rolling`](io.jstach.rainbowgum.file/module-summary.html) | output | [rainbowgum-file](io.jstach.rainbowgum.file/module-summary.html) |
| [`jfr`](io.jstach.rainbowgum.jfr/module-summary.html) | output | [rainbowgum-jfr](io.jstach.rainbowgum.jfr/module-summary.html) |
| [`otlp`](io.jstach.rainbowgum.otlp/module-summary.html) | output and encoder | [rainbowgum-otlp](io.jstach.rainbowgum.otlp/module-summary.html) |
| [`disruptor`](io.jstach.rainbowgum.disruptor/module-summary.html) | publisher | [rainbowgum-disruptor](io.jstach.rainbowgum.disruptor/module-summary.html) |

Application code that uses the SLF4J API also needs `org.slf4j:slf4j-api` at compile scope, since [rainbowgum](io.jstach.rainbowgum.bundle/module-summary.html) is normally a runtime dependency. For a more minimal setup (total application size in terms of classes) [rainbowgum-core](io.jstach.rainbowgum/module-summary.html) and [rainbowgum-slf4j](io.jstach.rainbowgum.slf4j/module-summary.html) (if using SLF4J) should be used.

> **Note**
>
> If you are using a web framework or platform that already bundles its own logging framework (Logback, Log4j2, etc.), you will likely need to exclude that transitive dependency, or the two will conflict on the SLF4J provider slot. See the [Spring Boot](#spring_boot) section below for a concrete example of excluding `spring-boot-starter-logging`.

### Maven <a id="maven"></a>

```xml
<properties>
    <rainbowgum.version>0.17.2</rainbowgum.version>
</properties>
...
<dependencies>
    <dependency>
        <groupId>io.jstach.rainbowgum</groupId>
        <artifactId>rainbowgum</artifactId>
        <version>${rainbowgum.version}</version>
        <scope>runtime</scope>
    </dependency>
</dependencies>
```

If you plan on configuring Rainbow Gum programmatically you will need to make a module and create a service loader registration. In that case you will want the dependency below, plus any module whose classes your configuration code uses (for example [rainbowgum-pattern](io.jstach.rainbowgum.pattern/module-summary.html) for `PatternEncoderBuilder`) at compile scope:

```xml
<properties>
    <rainbowgum.version>0.17.2</rainbowgum.version>
</properties>
...
<dependencies>
    <dependency>
        <groupId>io.jstach.rainbowgum</groupId>
        <artifactId>rainbowgum-core</artifactId>
        <version>${rainbowgum.version}</version>
        <scope>compile</scope>
    </dependency>
</dependencies>
```

### Gradle <a id="3.2"></a>

Groovy DSL (`build.gradle`):

```groovy
dependencies {
    runtimeOnly 'io.jstach.rainbowgum:rainbowgum:0.17.2'
}
```

Kotlin DSL (`build.gradle.kts`):

```kotlin
dependencies {
    runtimeOnly("io.jstach.rainbowgum:rainbowgum:0.17.2")
}
```

If you plan on configuring Rainbow Gum programmatically you will need to make a module and create a service loader registration. In that case you will want the dependency below, plus any module whose classes your configuration code uses (for example [rainbowgum-pattern](io.jstach.rainbowgum.pattern/module-summary.html) for `PatternEncoderBuilder`) at compile scope:

```groovy
dependencies {
    implementation 'io.jstach.rainbowgum:rainbowgum-core:0.17.2'
}
```

```kotlin
dependencies {
    implementation("io.jstach.rainbowgum:rainbowgum-core:0.17.2")
}
```

## Extensions and Integrations <a id="integration"></a>

### SLF4J 2.0 <a id="slf4j"></a>

Rainbow Gum SLF4J module [rainbowgum-slf4j](io.jstach.rainbowgum.slf4j/module-summary.html) supports:

- [MDC](https://slf4j.org/manual.html#mdc)
- [Fluent Logging API](https://slf4j.org/manual.html#fluent)
- [Decorating loggers](io.jstach.rainbowgum.slf4j/io/jstach/rainbowgum/slf4j/spi/LoggerDecoratorService.html)
- [Caller Information](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEvent.Caller.html)

> <a id="slf4j_platform_logging"></a>**Warning: do not use slf4j-jdk-platform-logging**
>
> SLF4J's `System.Logger` adapter, `org.slf4j:slf4j-jdk-platform-logging`, formats each message with [`MessageFormat`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/text/MessageFormat.html) and then passes the same parameters on as SLF4J arguments, so SLF4J substitutes `{}` a second time in text that already contains the parameter values ([slf4j#498](https://github.com/qos-ch/slf4j/pull/498)). A parameter value containing `{}`, for example one that came from user input, is replaced by another parameter, and parameters the pattern never referenced are logged. A malformed pattern makes `System.Logger.log` throw [`IllegalArgumentException`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/IllegalArgumentException.html). With SLF4J 2.0.20 and Rainbow Gum's SLF4J module:
>
> ```java
> logger.log(Level.INFO, "a={0} b={1}", "X", "{}");             // a=X b=X
> logger.log(Level.INFO, "user={0}", "{} {}", "unreferenced");  // user={} {} unreferenced
> ```
>
> Rainbow Gum's own [`System.Logger` integration](#system_logger) logs these as `a=X b={}` and `user={} {}`. It is part of the [rainbowgum](io.jstach.rainbowgum.bundle/module-summary.html) dependency, so the adapter is not needed. If both are present the JDK uses whichever `System.LoggerFinder` it finds first, which on the class path depends on jar order, so make sure the adapter is not a transitive dependency (`mvn dependency:tree`).

MDC defaults to a [`ThreadLocal`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ThreadLocal.html)-backed implementation; setting `logging.mdc.type` to `NOOP` swaps in a no-op implementation instead, for deployments that want no [`ThreadLocal`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ThreadLocal.html) anywhere in the logging path and are fine losing MDC to get it.

There is no built-in [`Marker`](https://www.slf4j.org/api/org/slf4j/Marker.html) support (it is not stored on the event or used for routing/filtering by default), but a [decorator](io.jstach.rainbowgum.slf4j/io/jstach/rainbowgum/slf4j/spi/AbstractFilteringLogger.html) can observe markers and act on them, e.g. surface one as a key value or filter on it.

Rainbow Gum supports key value pairs in [`LoggingEventBuilder`](https://www.slf4j.org/api/org/slf4j/spi/LoggingEventBuilder.html) by overlaying on top of the current MDC at the time the event is constructed and put into the [`events key values`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEvent.html#keyValues(%29). The value parameter in [`LoggingEventBuilder.addKeyValue(String,Object)`](https://www.slf4j.org/api/org/slf4j/spi/LoggingEventBuilder.html#addKeyValue(java.lang.String,java.util.function.Supplier%29) are converted to [`String`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/String.html) immediately as only String values are supported at this time.

> <a id="key_values_sensitive"></a>**Warning: key values are logged**
>
> Key values from MDC, [`LoggingEventBuilder.addKeyValue(String,Object)`](https://www.slf4j.org/api/org/slf4j/spi/LoggingEventBuilder.html#addKeyValue(java.lang.String,java.util.function.Supplier%29), [scoped key values](#scoped_key_values) and other sources are written by the default [TTLL format](#ttll), so they appear in console output without any configuration, and the [JSON encoders](#json_encoders) include them. Do not put passwords, tokens, session ids or personal data in key values. If you are coming from a framework whose default format leaves MDC out, values that never showed up in your logs before will now. TTLL's `keyValues=none` leaves them out of the text format, and `logging.keyvalues.sources` selects which sources add key values to events (see [key value sources](#key_value_sources)).

Rainbow Gum SLF4J implementation is unique in that it has two special implementation of loggers:

- Level Logger: logger based on level threshold and *can never change*!
- Changing Logger: level and other configuration *can change*.

Other logging implementations like Logback by default use something analogous to changing loggers which require a constant check if the level threshold has changed. Level loggers do not need to do that check. Unless [changing loggers is turned on](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.ChangePublisher.html) by default Level Loggers are used which are close to zero cost for discarding events.

The SLF4J API does not document nullability for [`MDCAdapter`](https://www.slf4j.org/api/org/slf4j/spi/MDCAdapter.html) or [`LoggingEventBuilder.addArgument(Object)`](https://www.slf4j.org/api/org/slf4j/spi/LoggingEventBuilder.html#addArgument(java.util.function.Supplier%29) (see [slf4j#493](https://github.com/qos-ch/slf4j/issues/493)). Rainbow Gum accepts `null` more widely than SLF4J's own signatures require, e.g. MDC values, and logged arguments, for compatibility with existing SLF4J usage and other implementations, but this is not a recommendation: prefer not passing `null` where SLF4J itself gives no guarantee it is supported.

Like SLF4J's own reference [`LoggingEventBuilder`](https://www.slf4j.org/api/org/slf4j/spi/LoggingEventBuilder.html) implementation, Rainbow Gum's is mutable: each fluent call mutates and returns the same instance rather than a new one.

### Scoped Key Values ([`ScopedValue`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ScopedValue.html) based MDC alternative) <a id="scoped_key_values"></a>

Rainbow Gum has an alternative to [MDC](https://slf4j.org/manual.html#mdc) for request/task-scoped key values, backed by [`ScopedValue`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ScopedValue.html) instead of [`ThreadLocal`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ThreadLocal.html): [`ScopedKeyValues`](io.jstach.rainbowgum.scopedkeyvalues/io/jstach/rainbowgum/scopedkeyvalues/ScopedKeyValues.html).

MDC's `ThreadLocal` storage has two long-standing problems this removes by construction:

- **Unbinding.** A value put on a pooled thread stays there until something remembers to call `MDC.remove(...)`, usually in a `finally` block. Forget one, or throw before reaching it, and the value leaks into whatever unrelated request or task happens to reuse that thread next.
- **Fan-out.** Nothing about `ThreadLocal` prevents one concurrent task from mutating values another sibling task (or the parent) is relying on, since they all just share the same backing map if it is naively passed around.

[`ScopedValue`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ScopedValue.html) bindings are immutable for the dynamic extent of one `ScopedValue.where(...).run(...)`/`.call(...)` call and are automatically, unconditionally unbound the instant that call returns, exception or not, with no `finally` required. A [`StructuredTaskScope`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/concurrent/StructuredTaskScope.html)<sup>[PREVIEW](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/concurrent/StructuredTaskScope.html#preview-java.util.concurrent.StructuredTaskScope)</sup> fork started inside that call inherits the binding as a frozen snapshot; nothing a sibling task or the parent does afterward can change what that snapshot contains, so correct fan-out isolation falls out of the JDK's own semantics instead of anything Rainbow Gum has to implement.

[`ScopedKeyValues`](io.jstach.rainbowgum.scopedkeyvalues/io/jstach/rainbowgum/scopedkeyvalues/ScopedKeyValues.html) pushes one small, immutable batch of key values at once, at a well-known request/task boundary, the same shape [JEP 506](https://openjdk.org/jeps/506)'s own examples use, not something called from every layer of business logic - typically a single push wrapping an entire request, e.g. in a servlet filter or similar entry point:

```java
// e.g. a servlet filter's doFilter, or any other single request/task entry point
ScopedKeyValues.builder()
    .add("requestId", requestId)
    .add("userId", userId)
    .run(() -> {
        // every log call for the duration of this Runnable/Callable, including inside
        // any StructuredTaskScope fork started in here, sees requestId/userId, e.g.:
        logger.info("handling request"); // logs with requestId and userId attached
        service.handle(request);
    });
```

> **Warning**
>
> Every value pushed here is on every log line for the whole request or task, including the default console output. Push identifiers such as a request id, not passwords, tokens or personal data; see [key values are logged](#key_values_sensitive).

This is deliberately **not** a replacement for MDC or for [`LoggingEventBuilder.addKeyValue(String,Object)`](https://www.slf4j.org/api/org/slf4j/spi/LoggingEventBuilder.html#addKeyValue(java.lang.String,java.util.function.Supplier%29). Ad-hoc, imperative, single-call-site key values are still MDC's/`addKeyValue`'s job - the two compose normally, since `ScopedKeyValues` is always merged in as the lowest-precedence source (see below), so an `addKeyValue(...)` call on one particular log line still overrides a key pushed here; this is for the opposite shape, a handful of values that should be visible on every log line for an entire request/task.

#### Two modules: API and provider <a id="scoped_key_values_modules"></a>

This feature is split into two modules the same way SLF4J itself is split into `slf4j-api` and a chosen binding:

- [rainbowgum-scopedkeyvalues-api](io.jstach.rainbowgum.scopedkeyvalues/module-summary.html) is the `compile`-scoped API application/library code depends on to call [`ScopedKeyValues`](io.jstach.rainbowgum.scopedkeyvalues/io/jstach/rainbowgum/scopedkeyvalues/ScopedKeyValues.html). It has no dependency beyond (optionally) JSpecify, does not reference [`ScopedValue`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ScopedValue.html) at all, and targets Rainbow Gum's usual JDK 21 baseline, so it is safe to depend on from code that has not committed to Rainbow Gum, or even to JDK 25, as its logging backend. It discovers the real storage mechanism at class-init time via a small `io.jstach.rainbowgum.scopedkeyvalues.spi.ScopedKeyValuesProvider` [`ServiceLoader`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/ServiceLoader.html) lookup, the same bootstrap shape SLF4J itself uses for `org.slf4j.spi.SLF4JServiceProvider`. With no provider found, pushing still runs the body normally, it just does not record or propagate anything, the same safe-with-nothing-bound behavior SLF4J's own facade falls back to.
- [rainbowgum-scopedkeyvalues](io.jstach.rainbowgum.scopedkeyvalues.provider/module-summary.html) is the `runtime`-scoped Rainbow Gum provider, like the rest of Rainbow Gum's optional modules. Simply depending on it is enough: it supplies the actual [`ScopedValue`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ScopedValue.html)-backed `ScopedKeyValuesProvider`, and separately registers a [`LogEventFactory`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEventFactory.html) in the [`ServiceRegistry`](io.jstach.rainbowgum/io/jstach/rainbowgum/ServiceRegistry.html) whose values are merged in as the *lowest*-precedence source underneath MDC, so MDC and any fluent builder `addKeyValue(...)` calls always win on a key collision, and nothing changes for applications that do not push anything.

**Requirement:** [`ScopedValue`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/ScopedValue.html) was finalized in JDK 25 ([JEP 506](https://openjdk.org/jeps/506)), higher than Rainbow Gum's usual JDK 21 baseline. Only the provider module targets JDK 25+; the API module does not, and is not part of the default [rainbowgum](io.jstach.rainbowgum.bundle/module-summary.html) dependency either way. Add both, with the API module at `compile` scope, unlike the rest of Rainbow Gum, which is `runtime`-scoped since application code is not meant to compile directly against implementation classes:

```xml
<dependency>
    <groupId>io.jstach.rainbowgum</groupId>
    <artifactId>rainbowgum-scopedkeyvalues-api</artifactId>
    <version>0.17.2</version>
    <scope>compile</scope>
</dependency>
<dependency>
    <groupId>io.jstach.rainbowgum</groupId>
    <artifactId>rainbowgum-scopedkeyvalues</artifactId>
    <version>0.17.2</version>
    <scope>runtime</scope>
</dependency>
```

### Default Key Values <a id="default_key_values"></a>

[rainbowgum-keyvalues-contributor](io.jstach.rainbowgum.keyvalues.contributor/module-summary.html) adds the same key values to every event, such as a build version or an instance id, without putting them in every thread's context. Every other key values source (SLF4J MDC, scoped key values, ...) overrides them on a key collision. Values come from a property, in the order they are declared:

```properties
logging.keyvalues.defaults=git.commit=abc123&instance.id=i-42
```

or from code, where they may change at any time; a property value wins over a value set in code for the same key:

```java
DefaultKeyValues.of(config.serviceRegistry()).put("app_status", "READY");
```

where `config` is the [`LogConfig`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html) of the running Rainbow Gum, for example `RainbowGum.of().config()`.

Values known at build time, such as a git commit id, should be set before the first event, which a [configurator](io.jstach.rainbowgum/io/jstach/rainbowgum/spi/RainbowGumServiceProvider.Configurator.html) does. One way to get the value into code is the `templating-maven-plugin`, which is how Rainbow Gum generates [`RainbowGumVersion`](io.jstach.rainbowgum/io/jstach/rainbowgum/RainbowGumVersion.html), filtering a class in `src/main/java-templates` with, for example, the `buildNumber` property of the `buildnumber-maven-plugin`:

```java
public final class BuildInfo {
	public static final String COMMIT = "${buildNumber}";
}

public final class BuildInfoConfigurator implements RainbowGumServiceProvider.Configurator {
	@Override
	public boolean configure(LogConfig config, Pass pass) {
		DefaultKeyValues.of(config.serviceRegistry()).put("git.commit", BuildInfo.COMMIT);
		return true;
	}
}
```

Register the configurator for the service loader in `META-INF/services/io.jstach.rainbowgum.spi.RainbowGumServiceProvider` (or with `provides` in `module-info.java`), or add it to a builder with [`LogConfig.Builder.configurator(io.jstach.rainbowgum.spi.RainbowGumServiceProvider.Configurator)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#configurator(io.jstach.rainbowgum.spi.RainbowGumServiceProvider.Configurator%29). Without code, a filtered properties resource can carry the value in the property instead.

Each change is copied once into an immutable snapshot that events share. When logs go through a collector such as the OpenTelemetry Collector, per process values like these usually belong in resource attributes instead, which the OTLP output and JSON encoders support.

```xml
<dependency>
    <groupId>io.jstach.rainbowgum</groupId>
    <artifactId>rainbowgum-keyvalues-contributor</artifactId>
    <version>0.17.2</version>
    <scope>runtime</scope>
</dependency>
```

<a id="key_value_sources"></a>`logging.keyvalues.sources` selects which [key value sources](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEventFactory.KeyValuesContributor.Source.Standard.html) add key values to events, as a comma separated list of `defaults`, `opentelemetry`, `scoped_key_values`, `jboss_logging`, `log4j2`, `slf4j` and `user`, ignoring case. When it is absent every source is selected, and an empty value selects none. A logging facade's own context store is always used for events logged through that facade, so `logging.keyvalues.sources=defaults` still puts the SLF4J MDC on events logged through SLF4J, but not on events logged through other facades. In code the same choice is [`LogConfig.Builder.keyValueSources(java.util.Set)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#keyValueSources(java.util.Set%29).

```properties
# only the default key values and the SLF4J MDC
logging.keyvalues.sources=defaults,slf4j
```

### java.lang.System.Logger and java.util.logging <a id="system_logger"></a>

Rainbow Gum [rainbowgum-jdk](io.jstach.rainbowgum.jdk/module-summary.html) module provides special integration and adapters for the builtin JDK logging facilities. The impetus for this is these logging facilities can be used early in the JDK boot processes well before logging has fully initialized. The default rainbow gum dependency has this integration as a transitive dependency.

The integration will make sure that the System.Logger does not initialize Rainbow Gum too early by queueing the events if some other facade is detected like SLF4J. When a Rainbow Gum initializes and [set as global](io.jstach.rainbowgum/io/jstach/rainbowgum/RainbowGum.html#set(io.jstach.rainbowgum.RainbowGum%29) the events will be replayed. If the events level are equal to [`System.Logger.Level.ERROR`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/System.Logger.Level.html#ERROR) and a normal Rainbow Gum has not been bound the messages will be printed to `System.err`. The idea is something catastrophic has happened that will probably cause Rainbow Gum to never load and thus never replay the events and you will not be able to figure out what happened otherwise.

The exception of the above is if [no other facade is detected](io.jstach.rainbowgum/io/jstach/rainbowgum/spi/RainbowGumServiceProvider.RainbowGumEagerLoad.html) the module will initialize Rainbow Gum. The idea is that your application only uses the JDK logging facilities (the Rainbow Gum SLF4J implementation is not found in the module/classpath). Thus only having the dependencies [rainbowgum-core](io.jstach.rainbowgum/module-summary.html), and [rainbowgum-jdk](io.jstach.rainbowgum.jdk/module-summary.html) will work as normal.

**java.util.logging records logged before Rainbow Gum starts are not queued.** Plain java.util.logging has no hook that lets Rainbow Gum load first, so the bridge handler is only installed when Rainbow Gum starts. Until then records go to java.util.logging's own configured handlers (by default its console handler on `System.err`, in its own format) and are not replayed; records logged after Rainbow Gum starts go through Rainbow Gum. To capture the early ones too, install the [Rainbow Gum `LogManager`](#jul_avoid), which makes java.util.logging itself load Rainbow Gum.

**[rainbowgum-jul](io.jstach.rainbowgum.jul/module-summary.html) by itself will not initialize Rainbow Gum the way [rainbowgum-jdk](io.jstach.rainbowgum.jdk/module-summary.html) does.** Depend on [rainbowgum-jdk](io.jstach.rainbowgum.jdk/module-summary.html) instead (which pulls [rainbowgum-jul](io.jstach.rainbowgum.jul/module-summary.html) in transitively) to get the JUL bridge activated automatically. If neither an existing `System.Logger`/SLF4J call site nor [rainbowgum-jdk](io.jstach.rainbowgum.jdk/module-summary.html) is an option, call [`RainbowGum.of()`](io.jstach.rainbowgum/io/jstach/rainbowgum/RainbowGum.html#of(%29) explicitly before any JUL logging happens. See [rainbowgum-jul](io.jstach.rainbowgum.jul/module-summary.html)'s module Javadoc for why.

> **Warning: do not use slf4j-jdk-platform-logging**
>
> SLF4J's [adapter for the System.Logger (org.slf4j:slf4j-jdk-platform-logging)](https://www.slf4j.org/manual.html#jep264) routes `System.Logger` calls into the bound SLF4J provider, but it formats parameters twice and can throw from `System.Logger.log`; see [the SLF4J section](#slf4j_platform_logging). [rainbowgum-jdk](io.jstach.rainbowgum.jdk/module-summary.html) (described above) gives the same `System.Logger` coverage plus `java.util.logging` bridging without those problems.

The following System properties allow greater control of the queueing and initialization. Because of how early initialization can happen this configuration can only be done with System properties.

- ["logging.global.queue.level"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#GLOBAL_QUEUE_LEVEL_PROPERTY) = level
- ["logging.global.queue.error"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#GLOBAL_QUEUE_ERROR_PROPERTY) = level
- ["logging.systemlogger.initialize"](io.jstach.rainbowgum.systemlogger/io/jstach/rainbowgum/systemlogger/RainbowGumSystemLoggerFinder.html#INITIALIZE_RAINBOW_GUM_PROPERTY) = init option

> **Note**
>
> While the JDK System.Logger is good for low level libraries that rarely log its API (and Rainbow Gum implementation) is not designed for performance. For applications and frameworks that do a lot of logging the SLF4J facade is the preferred choice.

Messages with parameters from java.util.logging, `System.Logger` and JBoss Logging are formatted with [`MessageFormat`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/text/MessageFormat.html) the way the JDK does: only when the message has an argument index such as `{0}`, so `It's done` with a parameter is logged as is, and a [`Throwable`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/Throwable.html) parameter is formatted like any other value; use the methods that take a `Throwable` to log its stack trace. If formatting fails, for example because of a malformed pattern or a parameter whose `toString()` throws, the raw message is logged followed by `[MessageFormat failed: `*reason*`]`. The event is never dropped and the logging call never throws.

["logging.messageformat.style"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#MESSAGE_FORMAT_STYLE_PROPERTY) changes this to follow another implementation:

- `jdk` (the default, alias `jboss`): as described above. JBoss LogManager formats the same way.
- `log4j2` (alias `logback`): `MessageFormat` is used whenever there are parameters, so `It's done` with a parameter is logged as `Its done`, and a trailing `Throwable` parameter is formatted and also logged with its stack trace. Logback formats the same way through SLF4J's `System.Logger` adapter.

Loggers follow the property of the Rainbow Gum that is currently bound, including loggers created before it started; while none is bound, before the first starts or after one is closed, the system property applies.

Events from java.util.logging (JUL) and System.Logger include key values from every registered source, such as the SLF4J MDC, when they are logged on the thread that set them. Caller info is not provided at this time. It may be added later as it does not depend on SLF4J; if you would like it please file an issue.

System Loggers created before Rainbow Gum starts follow it, including level changes. Loggers created after it starts keep the level resolved when they were created, unless level changes are allowed for them with ["logging.change.logger"](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#CHANGE_LOGGER_PREFIX); see [Config Change during runtime](#config_change).

#### Avoid java.util.logging if you can <a id="jul_avoid"></a>

Since [JEP 264](https://openjdk.org/jeps/264) (JDK 9), the JDK's own internals log through `java.lang.System.Logger`, not `java.util.logging` - JUL is no longer something the platform itself leans on, and today is mostly a legacy API kept alive by libraries and frameworks that predate JEP 264, or that have simply never migrated off it. If you have any choice in the matter (your own code, or a dependency you can swap), preferring SLF4J or `System.Logger` directly avoids JUL's dispatch overhead entirely rather than routing around it.

As a last resort, if some required dependency logs through JUL directly with no other integration seam, [rainbowgum-jul-logmanager](io.jstach.rainbowgum.jul.logmanager/module-summary.html) provides [`RainbowGumLogManager`](io.jstach.rainbowgum.jul.logmanager/io/jstach/rainbowgum/jul/logmanager/RainbowGumLogManager.html), a `java.util.logging.LogManager` replacement - see its own javadoc for installation and GraalVM native-image notes. It is a more invasive, JVM-wide alternative to the default [rainbowgum-jul](io.jstach.rainbowgum.jul/module-summary.html) bridge, worth reaching for only when the bridge genuinely cannot see a given `Logger` in time.

### Simple logging and properties <a id="simple_integration"></a>

#### rainbowgum-simple <a id="simple_bundle"></a>

[rainbowgum-simple](#simple_bundle) is a ready-to-use bundle for tests and low dependency applications. It pulls in [rainbowgum-slf4j](io.jstach.rainbowgum.slf4j/module-summary.html) through the [rainbowgum](io.jstach.rainbowgum.bundle/module-summary.html) dependency, along with JDK logging integrations and [rainbowgum-simple-props](io.jstach.rainbowgum.simple.props/module-summary.html). Adding it activates logging without application code or a configuration file. It formats with the core [formatters](#formatters), [TTLL](#ttll) by default; add [rainbowgum-pattern](io.jstach.rainbowgum.pattern/module-summary.html) for [pattern encoders](#pattern). For library tests, use Maven's `test` scope:

```xml
<dependency>
    <groupId>io.jstach.rainbowgum</groupId>
    <artifactId>rainbowgum-simple</artifactId>
    <version>0.17.2</version>
    <scope>test</scope>
</dependency>
```

Use `runtime` scope instead when an application uses the bundle. Place an optional `logging.properties` in `src/test/resources` or `src/main/resources`, respectively. The bundle is similar in purpose to [slf4j-simple](https://www.slf4j.org/apidocs/org/slf4j/simple/SimpleLogger.html), with [JDK logging support](#system_logger) and the property sources described below.

#### rainbowgum-simple-props <a id="simple_props"></a>

Add [rainbowgum-simple-props](io.jstach.rainbowgum.simple.props/module-summary.html) to an existing Rainbow Gum setup when you want its property loading without the entire simple bundle. For example, alongside the standard [rainbowgum](io.jstach.rainbowgum.bundle/module-summary.html) dependency (see [Maven](#maven)):

```xml
<dependency>
    <groupId>io.jstach.rainbowgum</groupId>
    <artifactId>rainbowgum-simple-props</artifactId>
    <version>0.17.2</version>
    <scope>runtime</scope>
</dependency>
```

##### Loading order <a id="simple_props_loading"></a>

**To opt in, having [rainbowgum-simple-props](io.jstach.rainbowgum.simple.props/module-summary.html) on the classpath or module path is not enough: `logging.properties` must exist** (or the base resource name chosen with [builder.resource](io.jstach.rainbowgum.simple.props/io/jstach/rainbowgum/simple/props/SimpleProperties.Builder.html#resource(java.lang.String%29)). Without that resource, this module contributes no properties, including system properties and environment variables, even when profiles were selected.

Once the base resource is found, property values resolve in this order (highest priority first):

1. The [level file](#simple_props_level_file), when watched, for `logging.level` keys only.
2. System properties.
3. `RAINBOWGUM_`-prefixed environment variables. For example, `logging.level.com.myapp` maps to `RAINBOWGUM_level_com_myapp` and the root `logging.level` to `RAINBOWGUM_level`. Set another prefix with `logging.simpleprops.envPrefix` in the base resource, the only place it is read, for example `logging.simpleprops.envPrefix=MYAPP_LOG_` for `MYAPP_LOG_level_com_myapp`. The prefix must end with `_` and must not start with `HTTP_`, which CGI and similar gateways set from request headers.
4. Selected `logging-<profile>.properties` classpath resources, with the first listed profile taking priority.
5. The base `logging.properties` classpath resource.

##### Profiles <a id="simple_props_profiles"></a>

Profile selection uses the first configured source in this order:

1. The `"logging.profiles"` system property, such as `-Dlogging.profiles=local-dev,dev`.
2. The `RAINBOWGUM_profiles` environment variable.
3. [builder.profiles](io.jstach.rainbowgum.simple.props/io/jstach/rainbowgum/simple/props/SimpleProperties.Builder.html#profiles(java.lang.String...%29).

- Each source replaces the whole profile list, including an explicitly empty list. Files cannot select additional profiles.
- Profile names allow ASCII letters, digits, underscores, and hyphens.
- When the base resource exists, every selected profile resource must also exist or startup fails, except for the optional `default` profile.

When no profiles are selected, the `default` profile loads `logging-default.properties` if it exists. Selecting other profiles replaces this default selection; values from that file are absent unless `default` is explicitly listed. Put settings such as a custom pattern there when another profile should be able to use Rainbow Gum's built-in defaults. Settings in `logging.properties` remain a fallback for every profile.

##### Level file <a id="simple_props_level_file"></a>

A level file changes log levels while the application runs, without a restart. Turn it on with `logging.simpleprops.levelFile=watch` (or `true`) as a system property, an environment variable, or in the base resource; it is off by default. The file is `level.properties` in the working directory unless `logging.simpleprops.levelFilePath` names another path, where a relative path is resolved against the working directory. Neither setting is read from profile resources or from the level file itself.

```properties
# level.properties
level.com.myco=debug
level.org.hibernate.SQL=trace
```

- Only `logging.level` keys are read, and like `logging.properties` they may leave off the `logging.` prefix. Other keys are ignored with a warning.
- Its levels win over every other source. That includes a [group](#level_groups) level: `level.web=DEBUG` in the file wins over a level set for a logger in `web` anywhere else. Groups themselves are defined in the application's properties, not in the level file.
- An edit with an invalid level is reported once and leaves all previously loaded levels unchanged. A later valid edit is applied normally.
- The file is checked for changes every two seconds, and changed levels apply to loggers that already exist. Watching supplies `logging.change.mode=on` and `logging.change.logger=level` as lowest precedence defaults, so explicit [change settings](#changing_resolving) still win.
- A missing file is picked up when it appears.
- Whoever can write the file controls what reaches the logs, so where POSIX permissions are available the file is refused while it or its directory can be written by group or others, or it is owned by someone other than the user running the application or root. A symbolic link also has its target's directory checked, and a missing link target is refused. A refused file is reported as an error alert, the last levels read are kept, and the file is read again once its permissions are fixed.

##### Diagnostics and native images <a id="simple_props_diagnostics"></a>

The provider records the selected profiles and each loaded resource as informational [`alerts`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html#alerts(%29). If the base resource is absent, it records that instead. Informational alerts are retained without printing to stderr by default.

Keys without the `logging.` prefix get it by default, in the base resource and in profile resources, so the file can leave it out:

```properties
level.com.myco=debug
appenders=console
```

is the same as `logging.level.com.myco=debug` and `logging.appenders=console`. When a key is given both ways the later line wins, as with any repeated key, and errors name the key as it is written in the file. Since a `java.util.logging` configuration file has the same name, a base resource with keys only it uses, such as `handlers`, `.level`, or `java.util.logging.ConsoleHandler.level`, stops initialization with an error saying it looks like `java.util.logging` configuration. This is the `short` mode of `logging.simpleprops.strict`, which itself is always written with its full key. Set `logging.simpleprops.strict=fail` in the base resource, or call [`SimpleProperties.builder().strict(StrictType.FAIL)`](io.jstach.rainbowgum.simple.props/io/jstach/rainbowgum/simple/props/SimpleProperties.Builder.html#strict(io.jstach.rainbowgum.simple.props.SimpleProperties.StrictType%29), to require the prefix instead: each unprefixed key then produces an error alert that includes its resource and line number, and initialization stops with an exception. `alert` reports the same errors and leaves stopping to [`logging.alerts.fail`](#troubleshooting_alerts_fail), which by default stops startup on them too, and `off` ignores unprefixed keys. The resource setting takes precedence over the builder. `false` is an alias for `off`; `true` is an alias for `fail`.

The module includes GraalVM native-image resource metadata for `logging.properties` and `logging-<profile>.properties`. Custom resource names need their own native-image metadata. For dynamic configuration or different property sources, use a custom [`RainbowGumServiceProvider.PropertiesProvider`](io.jstach.rainbowgum/io/jstach/rainbowgum/spi/RainbowGumServiceProvider.PropertiesProvider.html) or [programmatic builders](#simple_example_builder).

### Spring Boot <a id="spring_boot"></a>

Rainbow Gum provides Spring Boot 3 and 4 support that is maintained by the Rainbow Gum project, as two separate modules/artifacts, one per Spring Boot major version. Rainbow Gum cannot compete with Spring Boot's own bundled Logback/Log4j2 integration on "we maintain this forever regardless of what Spring Boot does next", so rather than bet on one major version staying source-compatible with the next (they usually are not), each supported major gets its own artifact:

- [rainbowgum-spring-boot4](io.jstach.rainbowgum.spring.boot4/module-summary.html) / [rainbowgum-spring-boot4-starter](io.jstach.rainbowgum.spring.boot4.starter/module-summary.html): for Spring Boot 4 **(recommended for new projects)**.
- [rainbowgum-spring-boot3](io.jstach.rainbowgum.spring.boot3/module-summary.html) / [rainbowgum-spring-boot3-starter](io.jstach.rainbowgum.spring.boot3.starter/module-summary.html): for Spring Boot 3.

Their own internal implementation packages (`io.jstach.rainbowgum.spring.boot3`/`boot4`) are not exported and never imported by consumers. Spring Boot discovers them itself through `META-INF/spring.factories` and the Java service loader, so those packages are duplicated per major version rather than shared, and are not necessarily identical in behavior. Each module's own javadoc has the authoritative full supported/not-supported property table for which Spring Boot logging properties (`logging.*`, `spring.output.ansi.enabled`, etc.) it supports, kept next to the code that implements it rather than duplicated here where it could drift out of sync: [rainbowgum-spring-boot4](io.jstach.rainbowgum.spring.boot4/module-summary.html) and [rainbowgum-spring-boot3](io.jstach.rainbowgum.spring.boot3/module-summary.html). The one package you might actually import, [`io.jstach.rainbowgum.spring.boot.spi`](io.jstach.rainbowgum.spring.boot.spi/io/jstach/rainbowgum/spring/boot/spi/package-summary.html), lives in its own genuinely shared module ([rainbowgum-spring-spi](io.jstach.rainbowgum.spring.boot.spi/module-summary.html), pulled in transitively by both starters) because it only depends on `org.springframework.core.env.Environment`, which is expected to remain stable across Spring Boot major versions, so if you have implemented `SpringRainbowGumServiceProvider` yourself, that import never needs to change when you bump major versions.

Spring Boot allows configuration through simple properties for logging that tries to be logging framework agnostic. How this works is Spring Boot configures the logging framework from its own set of properties. There is a shocking amount of code Spring Boot requires to do this for Logback and Log4J2 because both of those frameworks were not designed well for programmatic configuration.

**Rainbow Gum key value configuration is purposely very similar and largely compatible with Spring Boot's** *however* Spring Boot still requires special integration if you would like to use its configuration system (for example `application.properties`). This is because Spring Boot uses/needs logging for initialization of its configuration system.

The recommended setup of Spring Boot 4 with Maven is:

```xml
  <dependencies>
     <dependency>
      <groupId>io.jstach.rainbowgum</groupId>
      <artifactId>rainbowgum-spring-boot4-starter</artifactId>
      <version>0.17.2</version>
    </dependency>
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-web</artifactId>
      <exclusions>
        <!--
          This is the important part as logback will be used otherwise
          regardless if rainbow gum spring boot integration is used.
        -->
        <exclusion>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-logging</artifactId>
        </exclusion>
      </exclusions>
    </dependency>
  </dependencies>
```

For Spring Boot 3 substitute [rainbowgum-spring-boot4-starter](io.jstach.rainbowgum.spring.boot4.starter/module-summary.html) with [rainbowgum-spring-boot3-starter](io.jstach.rainbowgum.spring.boot3.starter/module-summary.html) above; everything else is identical. Note that if one chooses to not use one of the `rainbowgum-spring-boot*-starter` artifacts or the underlying [rainbowgum-spring-boot3](io.jstach.rainbowgum.spring.boot3/module-summary.html)/[rainbowgum-spring-boot4](io.jstach.rainbowgum.spring.boot4/module-summary.html) module directly, Spring will re-initialize `java.util.logging` and take over it so again the integration is recommended.

#### Actuator <a id="spring_boot_actuator"></a>

[rainbowgum-spring-boot4-actuator](io.jstach.rainbowgum.spring.boot4.actuator/module-summary.html) bridges Rainbow Gum's own diagnostics into Spring Boot 4's Actuator endpoints: every [`LogMetrics.StandardMetric`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.StandardMetric.html) as a Micrometer counter or gauge, and the [diagnostic report](#reporting) as Actuator info. Both activate independently of each other; neither requires a bean to register.

**Metrics.** Every [`LogMetrics.StandardMetric`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.StandardMetric.html) is bridged to Micrometer as `rainbowgum.<name>`, tagged with its level. Increasing metrics use counters (e.g. `rainbowgum.events.dropped`); `rainbowgum.events.queued` uses a gauge. It activates automatically (no properties to set) as long as Micrometer is on the classpath, which it already is once `spring-boot-starter-micrometer-metrics` (Spring Boot 4's own dedicated metrics starter) is a dependency; add just the module and the metrics show up under `/actuator/metrics` and any Micrometer registry the application already has configured (Prometheus, etc.).

Only the fixed `StandardMetric` set is bound: deliberately not the per-logger-name counters [`LogMetrics`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogMetrics.html) also accumulates as a side effect of every alert, since logger names are application-chosen and effectively unbounded, which would be an unbounded cardinality source in a metrics backend. [`LogAlerts`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAlerts.html) itself is not bridged to Micrometer at all; only its metrics side effect is.

**Info.** An `InfoContributor` renders the [[`LogReporter`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogReporter.html)](#reporting) to `/actuator/info`: one map entry per [`LogReporter.Section`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogReporter.Section.html) (`version`, `components`, `metrics`, `alerts`, `loggers`, `facades`; not `read_properties`, since info is often exposed more widely than property values should be), nested under a single `rainbowgum` key so it cannot collide with any other contributor's own top level keys. Unlike the metrics bridge above, this is **disabled by default** and needs `management.info.rainbowgum.enabled=true` set explicitly: the report can include internal detail (appender/output/encoder names, URIs), matching how Spring Boot's own `env`/`java`/`os`/`process` info contributors are also disabled unless explicitly enabled, for the same reason.

There is currently no Spring Boot 3 equivalent of this module; it is Boot 4 only.

### Helidon <a id="helidon"></a>

Rainbow Gum provides Helidon SE support through [rainbowgum-helidon4](io.jstach.rainbowgum.helidon4/module-summary.html) and [rainbowgum-helidon27](io.jstach.rainbowgum.helidon27/module-summary.html), native implementations of Helidon's own `io.helidon.logging.common.spi.LoggingProvider` extension point (the same one `helidon-logging-jul`/`helidon-logging-log4j` implement). Like Spring Boot, each supported Helidon major version gets its own artifact rather than one module trying to track every release:

- [rainbowgum-helidon4](io.jstach.rainbowgum.helidon4/module-summary.html): for Helidon SE 4.x.
- [rainbowgum-helidon27](io.jstach.rainbowgum.helidon27/module-summary.html): for Helidon SE 27.x, which requires Java 27.

Add the dependency and it activates automatically. No code change is needed at all: Helidon's own `LogConfig` selects and initializes the highest weighted `LoggingProvider` it finds before config, the service registry, or the webserver ever start, well before any application log line. See [rainbowgum-helidon4](io.jstach.rainbowgum.helidon4/module-summary.html)'s own module Javadoc for the full mechanism.

The recommended setup with Maven is (use [rainbowgum-helidon27](io.jstach.rainbowgum.helidon27/module-summary.html) for Helidon 27):

```xml
  <dependencies>
    <dependency>
      <groupId>io.jstach.rainbowgum.helidon</groupId>
      <artifactId>rainbowgum-helidon4</artifactId>
      <version>0.17.2</version>
    </dependency>
    <dependency>
      <groupId>io.jstach.rainbowgum</groupId>
      <artifactId>rainbowgum-simple-props</artifactId>
      <version>0.17.2</version>
    </dependency>
    <dependency>
      <groupId>io.jstach.rainbowgum</groupId>
      <artifactId>rainbowgum-pattern</artifactId>
      <version>0.17.2</version>
    </dependency>
  </dependencies>
```

[rainbowgum-simple-props](io.jstach.rainbowgum.simple.props/module-summary.html) and [rainbowgum-pattern](io.jstach.rainbowgum.pattern/module-summary.html) are not required by the Helidon modules themselves. Together they give a classpath `logging.properties` file (Rainbow Gum's own property format, not `java.util.logging`'s) and a pattern based encoder, the same combination this repository's own `examples/helidon` uses.

Both Helidon modules pull in [rainbowgum-jdk](io.jstach.rainbowgum.jdk/module-summary.html) at runtime scope, providing both `java.lang.System.Logger` support through [rainbowgum-systemlogger](io.jstach.rainbowgum.systemlogger/module-summary.html) and `java.util.logging` (JUL) bridging through [rainbowgum-jul](io.jstach.rainbowgum.jul/module-summary.html). This covers JDK and library calls to `System.Logger` as well as Helidon's own JUL logging. The Helidon `LoggingProvider` bootstraps Rainbow Gum; [rainbowgum-jul](io.jstach.rainbowgum.jul/module-summary.html) then installs the bridge `Handler`. No separate JDK logging dependency is needed.

### Micronaut <a id="micronaut"></a>

Micronaut fully embraces SLF4J as its own facade, so [rainbowgum-slf4j](io.jstach.rainbowgum.slf4j/module-summary.html) alone is a complete, low effort integration: no bootstrap ordering to worry about, since Micronaut's own internals call `LoggerFactory.getLogger(...)` immediately on startup. Rainbow Gum also provides [rainbowgum-micronaut5](#micronaut), a native `io.micronaut.management.endpoint.loggers.ManagedLoggingSystem` bean, closing two gaps that plain SLF4J alone leaves open:

- Micronaut's own `/loggers` management endpoint needs a bean of that type, and the bundled candidates for Logback/Log4j2 both disable themselves once those frameworks are not on the classpath, leaving nothing for a Rainbow Gum based application to fall back on.
- `application.properties`/`application.yml`'s own `logger.levels.*` keys have no effect on Rainbow Gum without this bean: Micronaut's bundled `PropertiesLoggingLevelsConfigurer` reads those keys and calls `setLogLevel(...)` on whichever `LoggingSystem` bean it finds, and without one, there is nothing to call.

Add the dependency and both are closed automatically: being a Micronaut bean is the entire integration, no [`ServiceLoader`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/ServiceLoader.html) registration or early lifecycle hook needed. [rainbowgum-micronaut5](#micronaut) has no `module-info.java` of its own (see its Javadoc jar's `Automatic-Module-Name`), so it is not part of this aggregated Javadoc, but its source is on GitHub for the full mechanism.

[rainbowgum-micronaut5](#micronaut) includes [rainbowgum-slf4j](io.jstach.rainbowgum.slf4j/module-summary.html), [rainbowgum-jdk](io.jstach.rainbowgum.jdk/module-summary.html), and [rainbowgum-pattern](io.jstach.rainbowgum.pattern/module-summary.html) as runtime dependencies. This provides the SLF4J implementation, `System.Logger` support, JUL bridging, and pattern encoding. Remove the application's existing logging implementation (e.g. `logback-classic`) and add the Micronaut integration:

```xml
  <dependency>
    <groupId>io.jstach.rainbowgum.micronaut</groupId>
    <artifactId>rainbowgum-micronaut5</artifactId>
    <version>0.17.2</version>
    <scope>runtime</scope>
  </dependency>
```

For classpath `logging.properties` loading, optionally add [rainbowgum-simple-props](io.jstach.rainbowgum.simple.props/module-summary.html), as this repository's `examples/micronaut` does for its configuration and smoke tests:

```xml
  <dependency>
    <groupId>io.jstach.rainbowgum</groupId>
    <artifactId>rainbowgum-simple-props</artifactId>
    <version>0.17.2</version>
    <scope>runtime</scope>
  </dependency>
```

That file uses Rainbow Gum's own property format, not `java.util.logging`'s. The Micronaut integration supports `logger.levels.*` in `application.properties`/`application.yml`, but does not expose Micronaut's environment as a general source of Rainbow Gum properties. Appender, output, and encoder settings can be supplied through `logging.properties` with [rainbowgum-simple-props](io.jstach.rainbowgum.simple.props/module-summary.html).

### JBoss Logging <a id="jboss_logging"></a>

[JBoss Logging](https://github.com/jboss-logging/jboss-logging) is sadly another logging facade, but unlike Commons Logging below it does not auto-select SLF4J just because `slf4j-api` is on the classpath - without help it silently falls back to `java.util.logging`, still reporting e.g. `isInfoEnabled()` correctly the whole time, so nothing looks broken.

The [rainbowgum-jboss-logging](io.jstach.rainbowgum.jbosslogging/module-summary.html) module is a true, native `LoggerProvider` implementation (not a bridge through SLF4J at all), registered the same way any [`ServiceLoader`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/ServiceLoader.html) provider is. Add the dependency and it is picked up automatically, no configuration needed:

```xml
<dependency>
  <groupId>io.jstach.rainbowgum</groupId>
  <artifactId>rainbowgum-jboss-logging</artifactId>
  <version>0.17.2</version>
</dependency>
```

If [rainbowgum-jboss-logging](io.jstach.rainbowgum.jbosslogging/module-summary.html) is not on the classpath, Rainbow Gum's SLF4J implementation still tries to help the SLF4J-bridge path along: when it initializes it sets `org.jboss.logging.provider=slf4j` if that system property is not already set.

```java
if (System.getProperty("org.jboss.logging.provider") == null) {
	System.setProperty("org.jboss.logging.provider", "slf4j");
}
```

This only helps if Rainbow Gum's SLF4J implementation happens to initialize before JBoss Logging's own `LoggerProviders` class loads - if a JBoss-Logging-using library logs something before the application has touched SLF4J at all, this is too late and the silent `java.util.logging` fallback still happens. [rainbowgum-jboss-logging](io.jstach.rainbowgum.jbosslogging/module-summary.html) does not have this ordering problem, since [`ServiceLoader`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/ServiceLoader.html) is consulted before any of JBoss Logging's own bridge fallbacks.

### Log4j2 <a id="log4j2"></a>

[Log4j2](https://logging.apache.org/log4j/2.x/) is a logging facade in its own right (not just an implementation) with a much larger method surface than SLF4J: dozens of per-level overloads across message type, parameter count, `Marker`, and [`Throwable`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/lang/Throwable.html).

The [rainbowgum-log4j2](io.jstach.rainbowgum.log4j/module-summary.html) module is a true, native `LoggerContextFactory` implementation (not a bridge through SLF4J at all), registered via [`ServiceLoader`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/ServiceLoader.html). Add the dependency and it is picked up automatically, no configuration needed:

```xml
<dependency>
  <groupId>io.jstach.rainbowgum</groupId>
  <artifactId>rainbowgum-log4j2</artifactId>
  <version>0.17.2</version>
</dependency>
```

Log4j2's `AbstractLogger` (the base class every real Log4j2 backend extends) absorbs almost all of that combinatorial surface itself: it declares no abstract methods of its own, funneling every overload down to three methods a backend must actually implement: `isEnabled(Level)`, `isEnabled(Level, Marker)`, and `logMessage(...)`, plus around fifteen further `isEnabled(Level, Marker, <message-type>, Throwable...)` overloads declared directly on `ExtendedLogger` that `AbstractLogger` leaves unimplemented (confirmed by inspection, matching `org.apache.logging.log4j:log4j-to-slf4j`'s own upstream reference implementation), all of which just delegate to the level+marker check since Rainbow Gum has no message-content-based filtering.

`Marker` is accepted but otherwise ignored, matching [rainbowgum-jboss-logging](io.jstach.rainbowgum.jbosslogging/module-summary.html)'s own treatment of markers: Rainbow Gum's router has no marker-based filtering or routing concept.

### Commons Logging (jcl) <a id="commons_logging"></a>

Commons Logging's own story has changed enough over time that it boils down to three cases, and in every one of them the fix is either nothing or a version bump, never `jcl-over-slf4j`:

**Commons Logging Cases**

| Case | What's actually happening | Action needed |
|---|---|---|
| Spring Framework 6 / Spring Boot 3 (or earlier) | Ships [spring-jcl](https://docs.spring.io/spring-framework/reference/core/spring-jcl.html) (Spring's own minimal `LogFactory`), which has auto-detected SLF4J (or the Log4j2 API) on the classpath since Spring Framework 5.0, falling back to `java.util.logging` only if neither is present. | Nothing. |
| Spring Framework 7 / Spring Boot 4 (or later) | `spring-jcl` was dropped; Spring depends directly on the real [Apache Commons Logging](https://commons.apache.org/proper/commons-logging/) (Spring Framework 7.0.0 pins 1.3.5). | Nothing. |
| Not using Spring, calling Commons Logging directly | Real Commons Logging's own `LogFactory` auto-detects `org.slf4j.Logger` on the classpath and self-selects an SLF4J-backed factory - but only since **1.3.0** (November 2023). | Upgrade to 1.3.0 or later. Rainbow Gum does not officially support Commons Logging older than that - there is no auto-detection to rely on before it. |

**`jcl-over-slf4j` is strongly discouraged**, not just unnecessary once on Commons Logging 1.3+: it ships its own `org.apache.commons.logging.LogFactory`/ `Log` classes under the exact same fully qualified names as real [Commons Logging](https://commons.apache.org/proper/commons-logging/). Having both on the classpath at once is not an error, it is a silent, classloader-order-dependent conflict over which jar's classes actually get loaded. Upgrade Commons Logging instead of reaching for it.

### Extension development guide <a id="plugin_guide"></a>

To a develop a custom plugin it is probably easiest to look at the other rainbow gum modules. An important concept with extensions are the registries which allow you to register a provider with a URI scheme.

1. [`LogPublisherRegistry`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogPublisherRegistry.html)
2. [`LogEncoderRegistry`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogEncoderRegistry.html)
3. [`LogOutputRegistry`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogOutputRegistry.html)

[`LogConfig`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.html) contains all the registries and a special generic registry: [`ServiceRegistry`](io.jstach.rainbowgum/io/jstach/rainbowgum/ServiceRegistry.html). The service registry is allows other plugins to share components. To access these registries at configuration time as a plugin is to implement a [`RainbowGumServiceProvider.Configurator`](io.jstach.rainbowgum/io/jstach/rainbowgum/spi/RainbowGumServiceProvider.Configurator.html).

Next one should construct builders that are properties friendly to create the components so that programmatic configuration users can use your extension. Rainbow Gum provides an annotation processor that helps create builders [rainbowgum-annotation](io.jstach.rainbowgum.annotation/module-summary.html).

```xml
<properties>
    <rainbowgum.version>0.17.2</rainbowgum.version>
</properties>
...
<dependencies>
    <dependency>
        <groupId>io.jstach.rainbowgum</groupId>
        <artifactId>rainbowgum-core</artifactId>
        <version>${rainbowgum.version}</version>
        <scope>compile</scope>
    </dependency>
    <!-- The generated builders use JSpecify nullness annotations -->
    <dependency>
        <groupId>org.jspecify</groupId>
        <artifactId>jspecify</artifactId>
        <version>1.0.1</version>
    </dependency>
</dependencies>
...
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-compiler-plugin</artifactId>
      <configuration>
        <!-- The annotation processor, which must never be a transitive dependency -->
        <annotationProcessorPaths>
          <path>
            <groupId>io.jstach.rainbowgum</groupId>
            <artifactId>rainbowgum-apt</artifactId>
            <version>${rainbowgum.version}</version>
          </path>
        </annotationProcessorPaths>
      </configuration>
    </plugin>
  </plugins>
</build>
```

The processor is listed in `annotationProcessorPaths` because JDK 23 and later no longer run annotation processors found only on the class path. The generated builders reference `org.jspecify.annotations.Nullable`, and JSpecify is not a transitive dependency of [rainbowgum-core](io.jstach.rainbowgum/module-summary.html), so it is declared too.

Once the annotation processor is enabled one can create a properties aware builder with a single static factory method annotated with [`LogConfigurable`](io.jstach.rainbowgum.annotation/io/jstach/rainbowgum/annotation/LogConfigurable.html). Mark a parameter that holds a secret with [`LogConfigurable.SensitiveParameter`](io.jstach.rainbowgum.annotation/io/jstach/rainbowgum/annotation/LogConfigurable.SensitiveParameter.html) so its value is redacted and cannot come from the component's URI.

### GraalVM Native Image <a id="graalvm_native"></a>

Rainbow Gum is designed to work under GraalVM native-image with no extra configuration on the consuming side. Modules that need native-image build arguments bundle their own `native-image.properties` (at `META-INF/native-image/io.jstach.rainbowgum/<i>artifact-name</i>/`), which native-image's own embedded configuration discovery picks up automatically from any jar on the build classpath. As of this writing, two modules bundle one:

- [rainbowgum-simple-props](io.jstach.rainbowgum.simple.props/module-summary.html) bundles a `resource-config.json` covering the default `logging.properties` resource name (see [`SimpleProperties`](io.jstach.rainbowgum.simple.props/io/jstach/rainbowgum/simple/props/SimpleProperties.html) for details), so it is included in the native image automatically.
- [rainbowgum-jdk](io.jstach.rainbowgum.jdk/module-summary.html) and [rainbowgum-systemlogger](io.jstach.rainbowgum.systemlogger/module-summary.html) (the `java.lang.System.LoggerFinder` integration) each bundle an `--initialize-at-build-time=...` argument, one covering `SystemLoggingFactory` plus a handful of core support classes (`RainbowGumHolder`, `LogProperties` and its `StandardProperties` helper, `PropertySuccess`, `ServiceLoaderCache`), the other covering `RainbowGumSystemLoggerFinder$RouterProvider` plus `GlobalLogRouter` and `StaticLevelResolver`. This exists because the JDK's own internals (`java.time`/`java.util.Locale` formatting, and separately `com.oracle.svm.core.jdk.TrustStoreManagerFeature` loading the default trust store at build time) call `System.getLogger(...)` incidentally, for their own diagnostics, from unrelated code paths that end up reachable during a real native-image build, and whichever registered `System.LoggerFinder` is on the classpath gets swept up regardless, along with whatever its resolution touches. While the image is being built the finder never starts a Rainbow Gum, so what gets frozen in for these specific classes is just the cheap "nothing bound yet" state (no real `RainbowGum` has loaded), the same state any freshly started JVM begins in, not anything environment-specific baked in from the build. See `io.jstach.rainbowgum.jdk.systemlogger.SystemLoggingFactory` (not part of [rainbowgum-jdk](io.jstach.rainbowgum.jdk/module-summary.html)'s exported API) and [`RainbowGumSystemLoggerFinder`](io.jstach.rainbowgum.systemlogger/io/jstach/rainbowgum/systemlogger/RainbowGumSystemLoggerFinder.html) for the exact flags and the full explanation.

If a native-image build reports a Rainbow Gum object in the image heap, build again with `--trace-object-instantiation=<the reported class>` and read who created it:

- If the trace shows a Rainbow Gum being started (`RainbowGum.of`, `RainbowGumServiceProvider.provide`, a configurator such as `JULConfigurator` installing a `java.util.logging` handler), something started logging during the build. That is a bug, not a missing flag: do not add `--initialize-at-build-time` for it. Rainbow Gum 0.17.0 and earlier start one this way when the JDK logs during the build and no SLF4J facade is on the class path. On those versions build the image with `-Dlogging.systemlogger.initialize=false` and start Rainbow Gum yourself at run time, for example with `RainbowGum.of()` first thing in `main`: that setting is frozen into the image, so the `System.Logger` finder will not start one at run time either.
- If instead the object only holds the "nothing bound yet" state described above, add its class to the relevant module's own `native-image.properties`, the same way the classes above were found.

#### Appender Locking Strategy: Native Image vs HotSpot <a id="graalvm_appender_type"></a>

Real-workload benchmarking (virtual threads, both platforms) found the two thread-local-buffer appender types trading places depending on how the process is actually running: [`LogAppender.AppenderType.SYNCHRONIZED_THREAD_LOCAL_BUFFER`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderType.html#SYNCHRONIZED_THREAD_LOCAL_BUFFER) wins by a real, repeatable, double-digit-percentage margin under GraalVM native-image, while the default, [`LogAppender.AppenderType.LOCK_THREAD_LOCAL_BUFFER`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderType.html#LOCK_THREAD_LOCAL_BUFFER), wins by a comparable margin on a regular JVM (HotSpot) - a genuine cross-over, not just a shrinking gap, so no single fixed choice is best on both.

This matters most for something distributed as more than one build of the same artifact for the same deployment - a native executable and a plain jar, say - where picking correctly per build would otherwise mean either shipping different configuration for each or sniffing the platform in application code. [`LogAppender.AppenderType.AUTO_DETECT`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderType.html#AUTO_DETECT) does that sniffing instead, resolving once, at appender construction time, to whichever of the two types wins on the platform actually running (via the same `org.graalvm.nativeimage.imagecode` system property check every native-image-aware framework uses, no GraalVM SDK dependency required):

```properties
logging.appender.console.type=auto_detect
```

Which concrete type a given platform resolves to today is an implementation detail of this heuristic, not a contract - the whole point of `auto_detect` is to track whichever choice is actually best, so that mapping may change in a future release. If a deployment needs a specific type to always be used, pick that type explicitly instead of relying on what `auto_detect` happens to resolve to right now.

**Not the default** - `auto_detect` must be requested explicitly, the same as any other non-default [`LogAppender.AppenderType`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderType.html).

#### Opting Every Appender/Encoder Into Platform-Specific Defaults At Once <a id="graalvm_global_optimize"></a>

Setting `auto_detect` per appender works, but it is still a choice made per appender, and [`LogAppender.AppenderType.AUTO_DETECT`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.AppenderType.html#AUTO_DETECT) is not the only place this project has found a platform-specific win - the same native-image benchmarking found `String.getBytes(Charset)`-based text encoding measurably faster there too, ahead of the default `CharsetEncoder`-based copy. `logging.global.optimize` opts every appender/encoder that has not been given a more specific, explicit choice into whichever of these this release currently believes is best for the platform actually running, all at once:

```properties
logging.global.optimize=true
```

An explicit choice always wins over this property, whether set programmatically (`appenderType(...)`, `useGetBytes(...)`) or via a more specific property ([`LogAppender.APPENDER_TYPE_PROPERTY`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAppender.html#APPENDER_TYPE_PROPERTY)) - this property only ever fills in what would otherwise be left unset.

**What this currently does, and why that is not a contract:** today it only has an effect under GraalVM native-image (detected the same way `auto_detect` is, above) - the default appender type becomes `auto_detect`, and text encoders default to `String.getBytes(Charset)`-based encoding. On a plain JVM this property currently changes nothing - the same benchmarking that motivated the native-image behavior pointed the other way on HotSpot. Exactly like `auto_detect` itself, none of this is a promise: as this project benchmarks more platforms, JDK versions, and encode strategies, what `logging.global.optimize` resolves to on a given platform - including whether it does anything on a plain JVM at all - can and will change between releases without notice. Pin an explicit appender type/encoder strategy instead if a deployment needs a specific one to always be used.

`test/rainbowgum-test-native` in the project's own repository is a working, end-to-end example: a small application depending only on [rainbowgum-simple](#simple_bundle) plus a custom, ServiceLoader-discovered [`RainbowGumServiceProvider.RainbowGumProvider`](io.jstach.rainbowgum/io/jstach/rainbowgum/spi/RainbowGumServiceProvider.RainbowGumProvider.html), built to a real native executable and run as a black-box smoke test in CI, with no manual native-image flags of its own.

## Troubleshooting <a id="troubleshooting"></a>

When logging does not do what you expect, run the application once with `-Dlogging.debug=help`:

```java
java -Dlogging.debug=help -jar app.jar
```

In `help` mode Rainbow Gum:

- prints the alerts it collected while loading properties and building its configuration, and the [diagnostic report](#reporting) of the components it actually wired up (the same output as `-Dlogging.debug=all`, see [Alerts](#alerts));
- lists every property key it read, with the value and where it came from for the ones that were set, so you can see what your configuration actually did and what else the chosen components read (see [below](#troubleshooting_read_properties));
- reports every property key that was set but not read during startup, with the key it was probably meant to be (see [below](#troubleshooting_unused_keys));
- fails startup if any warning or error alert was recorded, including a misspelled key, so the run stops with the reasons in front of you.

For example, misspelling a TTLL encoder property on the command line:

```java
java -Dlogging.debug=help -Dlogging.appender.console.encoder.uri=ttll \
  -Dlogging.appender.console.encoder.ttll.levle=plain -jar app.jar
```

prints the report and then:

```java
[WARN] - RAINBOW_GUM - LogConfig - Property key 'logging.appender.console.encoder.ttll.levle' from SYSTEM_PROPERTIES[logging.appender.console.encoder.ttll.levle] was set but not read during startup. Did you mean 'logging.appender.console.encoder.ttll.level'?
java.lang.IllegalStateException: 1 alert(s) at warning or above were recorded while starting and logging.debug=help:
[WARNING] Property key 'logging.appender.console.encoder.ttll.levle' from SYSTEM_PROPERTIES[logging.appender.console.encoder.ttll.levle] was set but not read during startup. Did you mean 'logging.appender.console.encoder.ttll.level'?
```

Because Rainbow Gum usually starts on the first logger an application asks for, the failure often surfaces wrapped in another exception (for example an `ExceptionInInitializerError` from a static logger field). The reason is in the cause, and it is also printed on its own just before the stack trace.

Like the other debug modes, `logging.debug` is read before any property source is loaded, so it is a system property (or the [`builder option`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#debug(io.jstach.rainbowgum.LogConfig.DebugModeType%29)) and cannot be set in `logging.properties`. Without it, startup still fails on configuration mistakes by default, but without printing anything extra, see [`logging.alerts.fail`](#troubleshooting_alerts_fail).

### Properties that were read <a id="troubleshooting_read_properties"></a>

The report printed in the `all` and `help` modes ends with every property key Rainbow Gum read while starting, in key order. A key that was set shows its value and where it came from; a key that was not set shows by itself. Since a component reads all of its keys under its own prefix, each chosen component's settings sit together, the ones you set next to the ones you could set. A parameter of a component's URI query is listed as the key it stands for. For example, part of the list for a `json5` console encoder:

```java
Read Properties:
  logging.appender.console.encoder.json5.color
  logging.appender.console.encoder.json5.format
  logging.appender.console.encoder.json5.keyValues = none ([logging.appender.console.encoder.uri]->URI(json5:///?keyValues=none)[keyValues])
  logging.appender.console.encoder.json5.prettyPrint
  logging.appender.console.encoder.json5.theme
  logging.appender.console.encoder.json5.thread = name (SIMPLE_PROPS[classpath:/logging.properties:3])
  logging.appender.console.encoder.postProcessors
  logging.appender.console.encoder.uri = json5:///?keyValues=none (SIMPLE_PROPS[classpath:/logging.properties:2])
```

A key that is set but missing from the list was not read, which is reported separately (see [below](#troubleshooting_unused_keys)): for example a `maxFileSize` on an output whose keys in the list have no `maxFileSize`, because a plain file output was chosen instead of a rolling one. Keys that end with a logger name, such as `logging.level.com.example`, are read as loggers are created, so the report printed at startup may not have them yet. Values of keys that look sensitive, such as ones containing `password` or `token`, are redacted, as are values of properties a component marks as sensitive, such as the OTLP output's `headers`. The same list is the [`LogReporter.Section.READ_PROPERTIES`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogReporter.Section.html#READ_PROPERTIES) section of a [report](#reporting), which is only filled in when reads are recorded.

### Misspelled and unused property keys <a id="troubleshooting_unused_keys"></a>

A misspelled property key is otherwise silently ignored: Rainbow Gum looks properties up by key, so a key nothing asks for does nothing. Unless [`logging.alerts.fail`](#troubleshooting_alerts_fail) is set so that it would not fail on a misspelled key, such as `off`, Rainbow Gum records every key it reads, and right after it starts it reports each key that was set but never read:

- An unread key close to a key that was read is reported as a **warning** with a suggestion. Close means the same key ignoring case, `-`, and `_` (`keyvalues`, `KEYVALUES`, and `key-values` all suggest `keyValues`), or at most two characters different (`apenders` suggests `appenders`). Suggestions only ever name keys that something actually read. A key that differs from the suggestion only in a component's name or type is information instead, since it may be for a component that was not chosen: with `logging.appenders=file1`, a `logging.appender.file2.output.uri` left in the configuration suggests `logging.appender.file1.output.uri` but does not fail startup.
- Any other unread key is reported as **information**. It may be a mistake, or it may be meant for a component that was not chosen, such as TTLL options left in `logging.properties` by a profile that switches the encoder to `json5`. A misspelled key of an encoder that was not chosen is also only information, since none of that encoder's keys were read to suggest. With the default unused-key level, only warnings can fail startup.
- A query parameter on a URI that the component it chose does not read is reported as a **warning**, as the key it stands for. For example `logging.appender.app.output.uri=./app.log?maxFileSize=10MB` chooses the plain file output, which has no `maxFileSize`; `rolling:///./app.log?maxFileSize=10MB` was meant.

`logging.alerts.unusedKey` makes this stricter for a configuration that should have no leftovers: `warning` (or `warn`) reports every unread key as a warning, and `error` as an error. With [`logging.alerts.fail`](#troubleshooting_alerts_fail) at the same level or below, any unread key then fails startup. The default, `info`, is the behavior above, and [`LogConfig.Builder.alertsUnusedKey(io.jstach.rainbowgum.LogAlerts.UnusedKeyLevel)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#alertsUnusedKey(io.jstach.rainbowgum.LogAlerts.UnusedKeyLevel%29) sets the default the property overrides.

```properties
# logging-ci.properties: fail on any key nothing reads
logging.alerts.unusedKey=warning
```

Keys are checked where Rainbow Gum can list them:

- System properties starting with `logging.`, always. A `-D` typo is the most common case and is caught without any other module.
- `logging.properties` and its profile files when using [rainbowgum-simple-props](io.jstach.rainbowgum.simple.props/module-summary.html).
- Any other property source implementing [`LogProperties.Listable`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.Listable.html). When the source renames keys, the suggestion also names what to set in that source, using its [description](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html#description(java.lang.String%29), for example `Did you mean 'logging.appenders' (environment variable APP_LOG_appenders)?`. The built in environment variables are not checked, because their names do not keep the dots and case of the keys.

Some keys are never reported: `logging.level` keys (and route level keys) and `logging.change.logger` keys, which are read per logger as loggers are created. A misspelled prefix such as `logging.levle.com.myapp` is therefore only information, since no level key is read up front to suggest. Also never reported are keys read before properties load, such as `logging.debug` and `logging.profiles`; and other libraries' system properties that happen to start with `logging.`, such as Spring Boot's `logging.config` and JBoss LogManager's `logging.configuration`. With `logging.alerts.fail=off`, or `error` while unused keys are below `error`, and debug mode not `all` or `help`, nothing is recorded and nothing is checked.

### Failing on alerts <a id="troubleshooting_alerts_fail"></a>

`logging.alerts.fail` fails startup when an [alert](#alerts) at or above a level is recorded while starting, similar to treating compiler warnings as errors. `config`, the default, fails on warnings and errors about configuration: misspelled keys, a URI query parameter nothing reads, a refused [level file](#simple_props_level_file), and a level that cannot be parsed. Problems while logging, such as an appender failing to write or an async publisher discarding events, are reported but do not stop the application. `warning` (or `warn` or `true`) fails on any warning or error, `error` on any error, and `off` (or `false`) never fails. A configuration source of your own marks its alerts with [`LogAlerts.config(java.lang.Class, java.lang.System.Logger.Level, java.lang.String, java.lang.Throwable)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAlerts.html#config(java.lang.Class,java.lang.System.Logger.Level,java.lang.String,java.lang.Throwable%29). Unlike `logging.debug` it is an ordinary property, so it can be set in `logging.properties`, a profile, a system property, or an environment variable, and [`LogConfig.Builder.alertsFail(io.jstach.rainbowgum.LogAlerts.FailLevel)`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogConfig.Builder.html#alertsFail(io.jstach.rainbowgum.LogAlerts.FailLevel%29) sets the default it overrides:

```properties
# logging-ci.properties, selected with -Dlogging.profiles=ci:
# also fail on problems while logging
logging.alerts.fail=warning
```

Alerts are checked when the configuration is built and again right after Rainbow Gum starts its components, which it closes again before failing. Alerts recorded after startup never fail anything. The failure lists only the alerts that crossed the level and says whether the level was the default; unlike debug mode it prints no report. `logging.alerts.unobservedErrorsAction` is different: it only acts on errors, and only when no alert listener is registered.

### Reporting a bug <a id="troubleshooting_bug_report"></a>

If the problem is still unclear, run with `-Dlogging.debug=help` (or `-Dlogging.debug=all` if you do not want the run to stop) and paste the printed alerts and report, from `Rainbow Gum started:` on, into a [GitHub issue](https://github.com/jstachio/rainbowgum/issues), along with the properties you set. The report shows the Rainbow Gum version, where properties came from, and which appenders, encoders, and outputs were actually chosen, which usually answers the first questions. Look it over before posting: alerts and errors can include property values.

## FAQ <a id="FAQ"></a>

### There is a typo in this documentation how can I fix it? <a id="faq_editdoc"></a>

If you would like to make corrections please file an issue or even better fork, edit, PR this file:

[`doc/overview.html`](https://github.com/jstachio/rainbowgum/blob/main/doc/overview.html)

### Where is the Javadoc? <a id="faq_javadoc"></a>

*Shockingly this document is the Javadoc!* To be precise it is the aggregate javadoc `overview.html`. The modules javadocs should be at the bottom of this document and the search bar at the top can be used to find documented classes.

## Modules <a id="all-modules-table"></a>

- [io.jstach.rainbowgum](io.jstach.rainbowgum/module-summary.html): Core module for RainbowGum which provides low level components for logging as well as a builder for creating custom RainbowGums.
- [io.jstach.rainbowgum.annotation](io.jstach.rainbowgum.annotation/module-summary.html): Rainbowgum Annotations used for code generation.
- [io.jstach.rainbowgum.avaje](io.jstach.rainbowgum.avaje/module-summary.html): Uses [Avaje Config](https://avaje.io/config/) for LogProperties.
- [io.jstach.rainbowgum.bundle](io.jstach.rainbowgum.bundle/module-summary.html): RainbowGum default grouping of modules transitively pulled in from Maven and module system.
- [io.jstach.rainbowgum.disruptor](io.jstach.rainbowgum.disruptor/module-summary.html): **EXPERIMENTAL** Disruptor async publisher.
- [io.jstach.rainbowgum.file](io.jstach.rainbowgum.file/module-summary.html): File output - [`FileOutput`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/file/FileOutput.html) registered under the `file` URI scheme - plus bare minimum size based rolling on top of it, see [`RollingFileOutput`](io.jstach.rainbowgum.file/io/jstach/rainbowgum/rolling/RollingFileOutput.html) for the full property list and scope - deliberately does not support calendar/date based rotation or Logback's own `fileNamePattern` conventions, only a numbered-suffix (`%i`) scheme.
- [io.jstach.rainbowgum.helidon27](io.jstach.rainbowgum.helidon27/module-summary.html): Rainbow Gum [Helidon](https://helidon.io) SE 27.x integration: implements Helidon's own `LoggingProvider` extension point (the same one `io.helidon.logging.jul.JulProvider`/ `io.helidon.logging.log4j.Log4jProvider` implement), registered via [`ServiceLoader`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/ServiceLoader.html).
- [io.jstach.rainbowgum.helidon4](io.jstach.rainbowgum.helidon4/module-summary.html): Rainbow Gum [Helidon](https://helidon.io) SE 4.x integration: implements Helidon's own `LoggingProvider` extension point (the same one `io.helidon.logging.jul.JulProvider`/ `io.helidon.logging.log4j.Log4jProvider` implement), registered via [`ServiceLoader`](https://docs.oracle.com/en/java/javase/27/docs/api/java.base/java/util/ServiceLoader.html).
- [io.jstach.rainbowgum.jansi](io.jstach.rainbowgum.jansi/module-summary.html): JANSI module that will install Jansi.
- [io.jstach.rainbowgum.jbosslogging](io.jstach.rainbowgum.jbosslogging/module-summary.html): Rainbow Gum [JBoss Logging](https://github.com/jboss-logging/jboss-logging) integration: a native `LoggerProvider` implementation, not a bridge through SLF4J.
- [io.jstach.rainbowgum.jdk](io.jstach.rainbowgum.jdk/module-summary.html): Rainbow Gum JDK components.
- [io.jstach.rainbowgum.jfr](io.jstach.rainbowgum.jfr/module-summary.html): Provides a [`LogOutput`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogOutput.html) that commits each log event as a [JDK Flight Recorder](https://docs.oracle.com/en/java/javase/21/docs/api/jdk.jfr/module-summary.html) event instead of writing bytes anywhere, with URI scheme ["jfr"](io.jstach.rainbowgum.jfr/io/jstach/rainbowgum/jfr/JfrLogOutput.html#JFR_SCHEME), as well as a [`LogAlerts.Listener`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogAlerts.Listener.html) that does the same for alerts (opt-in, see [`JfrAlertListenerConfigurator`](io.jstach.rainbowgum.jfr/io/jstach/rainbowgum/jfr/JfrAlertListenerConfigurator.html)).
- [io.jstach.rainbowgum.json](io.jstach.rainbowgum.json/module-summary.html): Provides JSON encoders.
- [io.jstach.rainbowgum.jul](io.jstach.rainbowgum.jul/module-summary.html): Rainbow Gum JUL (`java.util.logging`) integration.
- [io.jstach.rainbowgum.jul.logmanager](io.jstach.rainbowgum.jul.logmanager/module-summary.html): A [`LogManager`](https://docs.oracle.com/en/java/javase/27/docs/api/java.logging/java/util/logging/LogManager.html) replacement that routes every `java.util.logging.Logger` directly through Rainbow Gum, bypassing the standard JUL Handler/Level dispatch machinery entirely.
- [io.jstach.rainbowgum.keyvalues.contributor](io.jstach.rainbowgum.keyvalues.contributor/module-summary.html): Key values added to every event, such as a build version or instance id, from properties or code.
- [io.jstach.rainbowgum.log4j](io.jstach.rainbowgum.log4j/module-summary.html): Rainbow Gum [Log4j2](https://logging.apache.org/log4j/2.x/) integration: a native `LoggerContextFactory` implementation, not a bridge through SLF4J.
- [io.jstach.rainbowgum.opentelemetry](io.jstach.rainbowgum.opentelemetry/module-summary.html): Adds the trace and span id of the current OpenTelemetry span to every event as the key values `traceId` and `spanId`, the names Micrometer Tracing uses and the OTLP output reads.
- [io.jstach.rainbowgum.otlp](io.jstach.rainbowgum.otlp/module-summary.html): OpenTelemetry Protocol (OTLP) log export without the OpenTelemetry SDK or any protobuf library: an OTLP/JSON lines encoder and an OTLP/HTTP output that sends either protobuf or JSON.
- [io.jstach.rainbowgum.pattern](io.jstach.rainbowgum.pattern/module-summary.html): Provides [Logback style pattern formatters.](https://logback.qos.ch/manual/layouts.html#ClassicPatternLayout) The URI scheme of pattern encoders is ["pattern"](io.jstach.rainbowgum.pattern/io/jstach/rainbowgum/pattern/format/PatternEncoder.html#PATTERN_SCHEME).
- [io.jstach.rainbowgum.scopedkeyvalues](io.jstach.rainbowgum.scopedkeyvalues/module-summary.html): A small, self-contained facade for request/task-scoped key values - see [`ScopedKeyValues`](io.jstach.rainbowgum.scopedkeyvalues/io/jstach/rainbowgum/scopedkeyvalues/ScopedKeyValues.html).
- [io.jstach.rainbowgum.scopedkeyvalues.provider](io.jstach.rainbowgum.scopedkeyvalues.provider/module-summary.html): The RainbowGum-backed `io.jstach.rainbowgum.scopedkeyvalues.spi.ScopedKeyValuesProvider` for `io.jstach.rainbowgum.scopedkeyvalues.ScopedKeyValues` - request/task-scoped key values backed by `java.lang.ScopedValue` instead of `ThreadLocal`.
- [io.jstach.rainbowgum.simple.props](io.jstach.rainbowgum.simple.props/module-summary.html): Loads [`LogProperties`](io.jstach.rainbowgum/io/jstach/rainbowgum/LogProperties.html) from system properties, environment variables, profile resources, and a classpath `logging.properties` resource.
- [io.jstach.rainbowgum.slf4j](io.jstach.rainbowgum.slf4j/module-summary.html): [SLF4J](https://slf4j.org) 2.0 implementation.
- [io.jstach.rainbowgum.spring.boot.spi](io.jstach.rainbowgum.spring.boot.spi/module-summary.html): Rainbow Gum Spring SPI: shared by `io.jstach.rainbowgum.spring.boot3` and `io.jstach.rainbowgum.spring.boot4`.
- [io.jstach.rainbowgum.spring.boot3](io.jstach.rainbowgum.spring.boot3/module-summary.html): Rainbow Gum Spring Boot 3 integration.
- [io.jstach.rainbowgum.spring.boot3.starter](io.jstach.rainbowgum.spring.boot3.starter/module-summary.html): Spring Boot 3 Rainbow Gum Integration.
- [io.jstach.rainbowgum.spring.boot4](io.jstach.rainbowgum.spring.boot4/module-summary.html): Rainbow Gum Spring Boot 4 integration.
- [io.jstach.rainbowgum.spring.boot4.actuator](io.jstach.rainbowgum.spring.boot4.actuator/module-summary.html): Rainbow Gum Spring Boot 4 Actuator/Micrometer integration.
- [io.jstach.rainbowgum.spring.boot4.starter](io.jstach.rainbowgum.spring.boot4.starter/module-summary.html): Spring Boot 4 Rainbow Gum Integration.
- [io.jstach.rainbowgum.systemlogger](io.jstach.rainbowgum.systemlogger/module-summary.html): This module provides a partial System.Logger implementation.
- [io.jstach.rainbowgum.tomcat](io.jstach.rainbowgum.tomcat/module-summary.html): Rainbow Gum Tomcat logging implementation usually for Spring Boot.
