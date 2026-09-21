using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Wms.Host.Migrator;

// wms-migrator job (spec §18.3): applies every module's migrations, then exits.
// Exit code 0 = all contexts migrated, 1 = at least one failed.
var configuration = new ConfigurationBuilder()
    .SetBasePath(AppContext.BaseDirectory)
    .AddJsonFile("appsettings.json", optional: true)
    .AddEnvironmentVariables()
    .AddCommandLine(args.Where(a => !string.Equals(a, "--seed", StringComparison.OrdinalIgnoreCase)).ToArray())
    .Build();

var services = new ServiceCollection();
services.AddLogging(logging => logging.AddSimpleConsole(options => options.SingleLine = true));
MigratorServices.Register(services, configuration);

await using var provider = services.BuildServiceProvider();
using var cancellation = new CancellationTokenSource();
Console.CancelKeyPress += (_, eventArgs) =>
{
    eventArgs.Cancel = true;
    cancellation.Cancel();
};

var runner = ActivatorUtilities.CreateInstance<MigrationRunner>(provider);
var exitCode = await runner.RunAsync(cancellation.Token).ConfigureAwait(false);
if (exitCode != 0)
{
    return exitCode;
}

// --seed fills the demo/warehouse data set. It is idempotent: re-running changes nothing.
// AddCommandLine drops a valueless switch, so the bare "--seed" form is matched against args directly.
var seedRequested = args.Any(a => string.Equals(a, "--seed", StringComparison.OrdinalIgnoreCase))
    || configuration.GetValue("seed", defaultValue: false);
if (!seedRequested)
{
    return 0;
}

using var seedScope = provider.CreateScope();
var seeder = ActivatorUtilities.CreateInstance<DemoSeeder>(seedScope.ServiceProvider);
return await seeder.RunAsync(cancellation.Token).ConfigureAwait(false);
