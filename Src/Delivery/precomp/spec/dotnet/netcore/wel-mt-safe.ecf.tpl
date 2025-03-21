<?xml version="1.0" encoding="ISO-8859-1"?>
<system xmlns="http://www.eiffel.com/developers/xml/configuration-1-21-0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.eiffel.com/developers/xml/configuration-1-21-0 http://www.eiffel.com/developers/xml/configuration-1-21-0.xsd" name="precomp_dotnet_wel-mt-safe" uuid="178082BF-D4B8-46D3-8C7C-B130655723F6" library_target="wel-mt-safe">
	<target name="wel-mt-safe">
		<description>WEL library in MT mode</description>
		<root all_classes="true"/>
		<option warning="error">
		</option>
		<setting name="dotnet_naming_convention" value="true"/>
		<setting name="executable_name" value="EiffelSoftware.Library.WelMt"/>
		<setting name="msil_generation" value="true"/>
		<setting name="msil_generation_type" value="dll"/>
		<setting name="msil_use_optimized_precompile" value="true"/>
		<setting name="msil_clr_version" value="${MSIL_CLR_VERSION}"/>
		<capability>
			<concurrency support="thread" use="thread"/>
		</capability>
		<precompile name="precompile" location="$ISE_PRECOMP\base-mt-safe.ecf"/>
		<library name="base" location="$ISE_LIBRARY\library\base\base.ecf"/>
		<library name="wel" location="$ISE_LIBRARY\library\wel\wel.ecf"/>
	</target>
</system>
