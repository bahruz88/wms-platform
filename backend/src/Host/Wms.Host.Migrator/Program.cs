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

// The iam catalogue (tenant, roles, the permission catalogue, role -> permission) is system reference data,
// not demo data: without it no request can be authorized and every audit column would have nobody to point
// at, so it is written on every migrator run. It is idempotent.
using (var catalogueScope = provider.CreateScope())
{
    var iamSeeder = ActivatorUtilities.CreateInstance<IamSeeder>(catalogueScope.ServiceProvider);
    var catalogueExit = await iamSeeder.SeedCatalogueAsync(cancellation.Token).ConfigureAwait(false);
    if (catalogueExit != 0)
    {
        return catalogueExit;
    }
}

// The report catalogue (TOR §29) is reference data too: with rpt_report_definition empty the reports screen
// is blank and every report code answers 404. Idempotent, like the iam catalogue.
using (var reportScope = provider.CreateScope())
{
    var reportSeeder = ActivatorUtilities.CreateInstance<ReportCatalogSeeder>(reportScope.ServiceProvider);
    var reportExit = await reportSeeder.SeedAsync(cancellation.Token).ConfigureAwait(false);
    if (reportExit != 0)
    {
        return reportExit;
    }
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
var demoExit = await seeder.RunAsync(cancellation.Token).ConfigureAwait(false);
if (demoExit != 0)
{
    return demoExit;
}

// Dev users come last: their location grants reference master_location rows the demo seeder creates.
var devUserSeeder = ActivatorUtilities.CreateInstance<IamSeeder>(seedScope.ServiceProvider);
return await devUserSeeder.SeedDevUsersAsync(cancellation.Token).ConfigureAwait(false);
