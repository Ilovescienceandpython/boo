#!env booi
#region license
// Copyright (c) 2004, Rodrigo B. de Oliveira (rbo@acm.org)
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright notice,
//     this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright notice,
//     this list of conditions and the following disclaimer in the documentation
//     and/or other materials provided with the distribution.
//     * Neither the name of Rodrigo B. de Oliveira nor the names of its
//     contributors may be used to endorse or promote products derived from this
//     software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#endregion

import System
import System.IO
import System.Linq
import Boo.Lang.Compiler.Ast.Visitors
import Boo.Lang.PatternMatching
import Boo.Lang.Parser

def Main(argv as (string)):
	
	print "{0,-5} {1,-7}  {2}" % ('tests', 'ignored', 'directory')
	
	GenerateIntegrationTestFixtures()
	
	GenerateTestFixture("regression", "BooCompiler.Tests/RegressionTestFixture.cs", "BooCompiler.Regression", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
	
		[TestFixture]
		public class RegressionTestFixture : AbstractCompilerTestCase
		{
	""")
	
	GenerateTestFixture("errors", "BooCompiler.Tests/CompilerErrorsTestFixture.cs", "BooCompiler.CompilerErrors", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
	
		[TestFixture]
		public class CompilerErrorsTestFixture : AbstractCompilerErrorsTestFixture
		{
	""")
	
	GenerateTestFixture("not-implemented", "BooCompiler.Tests/NotImplementedErrorsTestFixture.cs", "BooCompiler.NotImplementedErrors", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
	
		[TestFixture]
		public class NotImplementedErrorsTestFixture : AbstractCompilerErrorsTestFixture
		{
	""")
	
	GenerateTestFixture("warnings", "BooCompiler.Tests/CompilerWarningsTestFixture.cs", "BooCompiler.CompilerWarnings", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
		using Boo.Lang.Compiler;
	
		[TestFixture]
		public class CompilerWarningsTestFixture : AbstractCompilerTestCase
		{
			protected override CompilerPipeline SetUpCompilerPipeline()
			{
				CompilerPipeline pipeline = new Boo.Lang.Compiler.Pipelines.Compile();
				pipeline.Add(new Boo.Lang.Compiler.Steps.PrintWarnings());
				return pipeline;
			}
	""")
	
	GenerateTestFixture("macros", "BooCompiler.Tests/MacrosTestFixture.cs", "BooCompiler.Macros", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
	
		[TestFixture]
		public class MacrosTestFixture : AbstractCompilerTestCase
		{
	""")
	
	GenerateTestFixture("stdlib", "BooCompiler.Tests/StdlibTestFixture.cs", "BooCompiler.Stdlib", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
	
		[TestFixture]
		public class StdlibTestFixture : AbstractCompilerTestCase
		{
	""")
	
	GenerateTestFixture("async", "BooCompiler.Tests/AsyncTestFixture.cs", "BooCompiler.Async", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;

		[TestFixture]
		public class AsyncTestFixture : AbstractCompilerTestCase
		{
	""")

	GenerateTestFixture("attributes", "BooCompiler.Tests/AttributesTestFixture.cs", "BooCompiler.Attributes", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
		using Boo.Lang.Compiler;
		using Boo.Lang.Compiler.Steps;
	
		[TestFixture]
		public class AttributesTestFixture : AbstractCompilerTestCase
		{
			override protected CompilerPipeline SetUpCompilerPipeline()
			{
				CompilerPipeline pipeline = new Boo.Lang.Compiler.Pipelines.ExpandMacros();
				pipeline.Add(new PrintBoo());
				return pipeline;
			}
	""")
	
	GenerateTestFixture("parser/roundtrip", "Boo.Lang.Parser.Tests/ParserRoundtripTestFixture.cs", "Boo.Lang.Parser", """
	namespace Boo.Lang.Parser.Tests
	{
		using NUnit.Framework;
	
		[TestFixture]
		public class ParserRoundtripTestFixture : AbstractParserTestFixture
		{
			void RunCompilerTestCase(string fname)
			{
				RunParserTestCase(fname);
			}
	""")
	
	PortParserTestCases()
	GenerateTestFixture("parser/wsa", "Boo.Lang.Parser.Tests/WSAParserRoundtripTestFixture.cs", "Boo.Lang.Parser", """
	namespace Boo.Lang.Parser.Tests
	{
		using NUnit.Framework;
	
		[TestFixture]
		public class WSAParserRoundtripTestFixture : AbstractWSAParserTestFixture
		{
			void RunCompilerTestCase(string fname)
			{
				RunParserTestCase(fname);
			}
	""")
	
	GenerateTestFixture("semantics", "BooCompiler.Tests/SemanticsTestFixture.cs", "BooCompiler.Semantics", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
		using Boo.Lang.Compiler;
		using Boo.Lang.Compiler.Pipelines;
	
		[TestFixture]
		public class SemanticsTestFixture : AbstractCompilerTestCase
		{
			protected override CompilerPipeline SetUpCompilerPipeline()
			{
				return new CompileToBoo();
			}
	""")
	
	GenerateTestFixture("ducky", "BooCompiler.Tests/DuckyTestFixture.cs", "BooCompiler.Ducky", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
		using Boo.Lang.Compiler;
		using Boo.Lang.Compiler.Pipelines;
	
		[TestFixture]
		public class DuckyTestFixture : AbstractCompilerTestCase
		{
			protected override void CustomizeCompilerParameters()
			{
				_parameters.Ducky = true;
			}
	""")
	
	GenerateTestFixture("net2/generics", "BooCompiler.Tests/GenericsTestFixture.cs", "BooCompiler.Generics", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
	
		[TestFixture]
		public class GenericsTestFixture : AbstractCompilerTestCase
		{
			override protected void RunCompilerTestCase(string name)
			{
				if (System.Environment.Version.Major < 2) Assert.Ignore("Test requires .net 2.");
				System.ResolveEventHandler resolver = InstallAssemblyResolver(BaseTestCasesPath);
				try
				{
					base.RunCompilerTestCase(name);
				}
				finally
				{
					RemoveAssemblyResolver(resolver);
				}
			}
	
			override protected void CopyDependencies()
			{
				CopyAssembliesFromTestCasePath();
			}
	""")
	
	GenerateTestFixture("net2/errors", "BooCompiler.Tests/Net2ErrorsTestFixture.cs", "BooCompiler.Net2Errors", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
	
		[TestFixture]
		public class Net2ErrorsTestFixture : AbstractCompilerErrorsTestFixture
		{
			override protected void RunCompilerTestCase(string name)
			{
				if (System.Environment.Version.Major < 2) Assert.Ignore("Test requires .net 2.");
				base.RunCompilerTestCase(name);
			}
	""")
	
	GenerateTestFixture("unsafe", "BooCompiler.Tests/UnsafeTestFixture.cs", "BooCompiler.Unsafe", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
	
		[TestFixture]
		public class UnsafeTestFixture : AbstractCompilerTestCase
		{
			protected override void CustomizeCompilerParameters()
			{
				_parameters.Unsafe = true;
			}
			
			protected override bool VerifyGeneratedAssemblies
			{
				get { return false; }
			}
	""")
	
	GenerateTestFixture("unsafe/errors", "BooCompiler.Tests/UnsafeErrorsTestFixture.cs", "BooCompiler.UnsafeErrors", """
	namespace BooCompiler.Tests
	{
		using NUnit.Framework;
	
		[TestFixture]
		public class UnsafeErrorsTestFixture : AbstractCompilerErrorsTestFixture
		{
			protected override void CustomizeCompilerParameters()
			{
				_parameters.Unsafe = true;
			}
	""")
	

def PortParserTestCases():
"""
Generates WSA parser test cases from
normal parser test cases.
"""
	for testcase in List of string(Directory.GetFiles("testcases/parser/roundtrip", "*.boo")).Sort():
		if not testcase.EndsWith(".boo"): continue

		fname = Path.GetFileName(testcase)
		wsaTestCase = Path.Combine("testcases/parser/wsa", fname)
		if not File.Exists(wsaTestCase):
			PortParserTestCase(testcase, wsaTestCase)
			print fname

def CopyDocstring(fname as string, writer as TextWriter):
	using file=File.OpenText(fname):
		tripleQuoteCount = 0
		for line in file:
			writer.WriteLine(line)
			if line.Trim() == '"""':
				++tripleQuoteCount
				break if tripleQuoteCount == 2

def PortParserTestCase(fromTestCase as string, toTestCase as string):
	using writer = StreamWriter(toTestCase):
		CopyDocstring(fromTestCase, writer)
		module=BooParser.ParseFile(fromTestCase).Modules[0]
		module.Accept(BooPrinterVisitor(writer, BooPrinterVisitor.PrintOptions.WSA))

def GetTestCaseName(fname as string):
	return join(
		(ch if char.IsLetterOrDigit(ch) else "_")
		for ch in Path.GetFileNameWithoutExtension(fname),"")

def MapPath(path):
#	return Path.Combine(Project.BaseDirectory, path)
	return Path.GetFullPath(path)

def WriteTestCases(writer as TextWriter, baseDir as string):
	count, ignored = 0, 0;
	testCasePath = MapPath("testcases/${baseDir}");
	System.IO.Directory.CreateDirectory(testCasePath);
	for fname as string in Directory.GetFiles(testCasePath):
		continue unless fname.EndsWith(".boo")
		attribute = CategoryAttributeFor(fname)
		
		ignore = attribute.StartsWith("[Ignore")
		++count unless ignore
		++ignored if ignore
		
		writer.Write("""
		${attribute}[Test]
		public void ${GetTestCaseName(fname)}()
		{
			RunCompilerTestCase(@"${NormalizePath(Path.GetFileName(fname))}");
		}
		""")
	print "{0,5} {1,7}  {2}" % (count, ignored, baseDir)
	
def CategoryAttributeFor(testFile as string):
"""
If the first line of the test case file starts with // category CategoryName 
then return a suitable [CategoryName()] attribute.
"""
	match FirstLineOf(testFile):
		case /\s*#\s*ignore\s+(?<reason>.*)/:
			return "[Ignore(\"${reason[0].Value.Trim()}\")]"
		case /\s*#\s*category\s+(?<name>.*)/:
			return "[Category(\"${name[0].Value.Trim()}\")]"
		otherwise:
			return ""
			
def FirstLineOf(fname as string):
	using reader=File.OpenText(fname):
		return reader.ReadLine()

def GenerateTestFixture(srcDir as string, targetFile as string, fixtureAssembly as string, header as string):
	using writer=StreamWriter(MapPath(targetFile)):
		writer.Write(ReIndent(header))
		WriteTestCases(writer, srcDir)
		writer.Write("""

		override protected string GetRelativeTestCasesPath()
		{
			return "${NormalizePath(srcDir)}";
		}
	}
}
""")

def NormalizePath(path as string):
	return path.Replace('\\', '/')

def GenerateIntegrationTestFixtures():
	for dir in Directory.GetDirectories("testcases/integration"):
		if /\.svn/.IsMatch(dir): continue
		GenerateIntegrationTestFixture("integration/${Path.GetFileName(dir)}")

def PascalCase(name as string):
	return name[:1].ToUpper() + name[1:]

def IntegrationTestFixtureName(dir as string):
	baseName = join(PascalCase(part) for part in /-/.Split(Path.GetFileName(dir)), '')
	return "${baseName}IntegrationTestFixture"

def GenerateIntegrationTestFixture(dir as string):
	fixtureName = IntegrationTestFixtureName(dir)
	header = """namespace BooCompiler.Tests
{
	using NUnit.Framework;

	[TestFixture]
	public class ${fixtureName} : AbstractCompilerTestCase
	{
	"""
	GenerateTestFixture(dir, "BooCompiler.Tests/${fixtureName}.cs", "BooCompiler.$(fixtureName.Replace('TestFixture', ''))", header)

def ReIndent(code as string):	
	lines = code.Replace("\r\n", "\n").Split(char('\n'))
	nonEmptyLines = line for line in lines if len(line.Trim())

	indentation = /(\s*)/.Match(nonEmptyLines.First()).Groups[0].Value
	return code if len(indentation) == 0

	buffer = System.Text.StringBuilder()
	for line in lines:
		if line.StartsWith(indentation):
			buffer.AppendLine(line[len(indentation):])
		else:
			buffer.AppendLine(line)
	return buffer.ToString()
	
