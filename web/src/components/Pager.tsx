import { useTranslation } from 'react-i18next';
import { Button } from '@ds/index';
import { formatCount } from '@core/format';
import { pageCount, type Page } from '@api/client';

/**
 * Paging control for `{ items, page, size, total }`. Sorting and filtering live on the screen —
 * `DataTable` deliberately knows nothing about them.
 */
export function Pager<T>({
  page,
  onPageChange,
}: {
  page: Page<T>;
  onPageChange: (next: number) => void;
}) {
  const { t } = useTranslation();
  const pages = pageCount(page);
  const from = page.total === 0 ? 0 : (page.page - 1) * page.size + 1;
  const to = Math.min(page.page * page.size, page.total);

  return (
    <div className="wms-pager">
      <span className="wms-num">
        {formatCount(from)}–{formatCount(to)} {t('common.of')} {formatCount(page.total)}{' '}
        {t('common.rows')}
      </span>
      <div className="wms-pager__controls">
        <Button
          size="sm"
          disabled={page.page <= 1}
          title={page.page <= 1 ? 'Bu, ilk səhifədir' : undefined}
          onClick={() => onPageChange(page.page - 1)}
        >
          {t('common.previous')}
        </Button>
        <span className="wms-num">
          {t('common.page')} {formatCount(page.page)} {t('common.of')} {formatCount(pages)}
        </span>
        <Button
          size="sm"
          disabled={page.page >= pages}
          title={page.page >= pages ? 'Bu, son səhifədir' : undefined}
          onClick={() => onPageChange(page.page + 1)}
        >
          {t('common.next')}
        </Button>
      </div>
    </div>
  );
}
