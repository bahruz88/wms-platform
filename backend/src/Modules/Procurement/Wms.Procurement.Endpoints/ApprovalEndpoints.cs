using Wms.Common.Application.Messaging;
using Wms.Common.Infrastructure.Auth;
using Wms.Common.Infrastructure.Http;
using Wms.Procurement.Application;
using Wms.Procurement.Application.Commands.ApprovalRules;
using Wms.Procurement.Application.Commands.Approvals;
using Wms.Procurement.Application.Queries;
using Wms.Procurement.Contracts;
using Wms.Procurement.Domain.Enums;

namespace Wms.Procurement.Endpoints;

/// <summary>
/// Operations <c>listPendingApprovals</c>, <c>getApproval</c>, <c>decideApproval</c>,
/// <c>listApprovalRules</c>, <c>createApprovalRule</c>, <c>updateApprovalRule</c>, <c>listPriceHistory</c>.
/// </summary>
public static class ApprovalEndpoints
{
    public static void Map(RouteGroupBuilder group)
    {
        ArgumentNullException.ThrowIfNull(group);

        group.MapGet("/approvals/pending", ListPendingAsync)
            .RequirePermission(ProcurementPermissions.ApprovalView)
            .WithName("listPendingApprovals");

        group.MapGet("/approvals/{id:long}", GetAsync)
            .RequirePermission(ProcurementPermissions.ApprovalView)
            .WithName("getApproval");

        group.MapPost("/approvals/{id:long}/decide", DecideAsync)
            .RequirePermission(ProcurementPermissions.ApprovalDecide)
            .RequireIdempotencyKey()
            .WithName("decideApproval");

        group.MapGet("/approval-rules", ListRulesAsync)
            .RequirePermission(ProcurementPermissions.ApprovalRuleView)
            .WithName("listApprovalRules");

        group.MapPost("/approval-rules", CreateRuleAsync)
            .RequirePermission(ProcurementPermissions.ApprovalRuleManage)
            .RequireIdempotencyKey()
            .WithName("createApprovalRule");

        group.MapPut("/approval-rules/{id:int}", UpdateRuleAsync)
            .RequirePermission(ProcurementPermissions.ApprovalRuleManage)
            .WithName("updateApprovalRule");

        group.MapGet("/price-history", ListPriceHistoryAsync)
            .RequirePermission(ProcurementPermissions.ProductViewCost)
            .WithName("listPriceHistory");
    }

    private static async Task<IResult> ListPendingAsync(
        [AsParameters] PendingApprovalsQueryRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var docType = EnumQuery.Parse<ApprovalDocType>(request.DocType, "docType");
        if (docType.IsFailure)
        {
            return docType.Error.ToProblem();
        }

        var query = new ListPendingApprovalsQuery(docType.Value, new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> GetAsync(long id, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var result = await dispatcher.QueryAsync(new GetApprovalQuery(id), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> DecideAsync(long id, ApprovalDecisionRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var decision = EnumQuery.Required<ApprovalDecision>(request.Decision, "decision");
        if (decision.IsFailure)
        {
            return decision.Error.ToProblem();
        }

        var command = new DecideApprovalCommand(id, decision.Value, request.Comment, request.ExpectedStepNo);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> ListRulesAsync([AsParameters] ApprovalRulesQueryRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        var docType = EnumQuery.Parse<ApprovalDocType>(request.DocType, "docType");
        if (docType.IsFailure)
        {
            return docType.Error.ToProblem();
        }

        var result = await dispatcher.QueryAsync(new ListApprovalRulesQuery(docType.Value, request.IsActive), cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> CreateRuleAsync(ApprovalRuleCreateRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var docType = EnumQuery.Required<ApprovalDocType>(request.DocType, "docType");
        if (docType.IsFailure)
        {
            return docType.Error.ToProblem();
        }

        var productType = EnumQuery.Parse<ApprovalProductType>(request.ProductType, "productType");
        if (productType.IsFailure)
        {
            return productType.Error.ToProblem();
        }

        var command = new CreateApprovalRuleCommand(
            docType.Value,
            productType.Value ?? ApprovalProductType.Any,
            request.MinAmountBase,
            request.MaxAmountBase,
            request.StepNo,
            request.ApproverRoleId,
            request.ApproverRoleCode ?? string.Empty);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToHttpResult(dto => TypedResults.Created($"{ProcurementRoutes.Prefix}/approval-rules/{dto.Id}", dto));
    }

    private static async Task<IResult> UpdateRuleAsync(uint id, ApprovalRuleUpdateRequest request, IDispatcher dispatcher, CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(request);
        var docType = EnumQuery.Required<ApprovalDocType>(request.DocType, "docType");
        if (docType.IsFailure)
        {
            return docType.Error.ToProblem();
        }

        var productType = EnumQuery.Parse<ApprovalProductType>(request.ProductType, "productType");
        if (productType.IsFailure)
        {
            return productType.Error.ToProblem();
        }

        var command = new UpdateApprovalRuleCommand(
            id,
            request.RowVersion,
            docType.Value,
            productType.Value ?? ApprovalProductType.Any,
            request.MinAmountBase,
            request.MaxAmountBase,
            request.StepNo,
            request.ApproverRoleId,
            request.ApproverRoleCode ?? string.Empty,
            request.IsActive);
        var result = await dispatcher.SendAsync(command, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }

    private static async Task<IResult> ListPriceHistoryAsync(
        [AsParameters] PriceHistoryQueryRequest request,
        IDispatcher dispatcher,
        CancellationToken cancellationToken)
    {
        var query = new ListPriceHistoryQuery(
            request.ProductId, request.SupplierId, request.DateFrom, request.DateTo, request.MinDiffPct, request.Sort,
            new PagingRequest(request.Page, request.Size).ToPageRequest());
        var result = await dispatcher.QueryAsync(query, cancellationToken).ConfigureAwait(false);
        return result.ToOk();
    }
}
