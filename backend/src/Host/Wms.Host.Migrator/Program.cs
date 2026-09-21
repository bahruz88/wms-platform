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
    .AddCommandLine(args)
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
return await runner.RunAsync(cancellation.Token).ConfigureAwait(false);
