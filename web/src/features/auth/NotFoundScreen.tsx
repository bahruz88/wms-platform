import { Link } from 'react-router-dom';
import { Alert } from '@ds/index';
import { Page } from '@/components/Page';

export function NotFoundScreen() {
  return (
    <Page title="Səhifə tapılmadı">
      <Alert tone="warning" title="Bu ünvanda ekran yoxdur" code="NOT_FOUND">
        Yazılan ünvan naviqasiyadakı heç bir ekrana uyğun gəlmir.{' '}
        <Link to="/">Dashboard-a qayıdın</Link>.
      </Alert>
    </Page>
  );
}
