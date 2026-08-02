import { BrowserRouter, Route, Routes } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import { MarketingLayout } from './components/MarketingLayout'
import { AccountDeletionPage } from './pages/AccountDeletionPage'
import { CancellationPage } from './pages/CancellationPage'
import { ContactPage } from './pages/ContactPage'
import { HomePage } from './pages/HomePage'
import { PrivacyPage } from './pages/PrivacyPage'
import { RefundPage } from './pages/RefundPage'
import { TermsPage } from './pages/TermsPage'
import { JoinGroupPage } from './pages/JoinGroupPage'
import { FriendInvitePage } from './pages/FriendInvitePage'
import { OAuthCallbackPage } from './pages/OAuthCallbackPage'
import { NotFoundPage } from './pages/NotFoundPage'
import { AppGate } from './routes/AppRoutes'
import { AppShell } from './components/app/AppShell'
import { OverviewPage } from './pages/app/OverviewPage'
import { GroupsPage } from './pages/app/GroupsPage'
import { GroupDetailPage } from './pages/app/GroupDetailPage'
import { FriendsPage } from './pages/app/FriendsPage'
import { FriendDetailPage } from './pages/app/FriendDetailPage'
import { AccountPage } from './pages/app/AccountPage'

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route element={<MarketingLayout />}>
            <Route index element={<HomePage />} />
            <Route path="join/:token" element={<JoinGroupPage />} />
            <Route path="invite/friend/:userId" element={<FriendInvitePage />} />
            <Route path="privacy" element={<PrivacyPage />} />
            <Route path="terms" element={<TermsPage />} />
            <Route path="refund" element={<RefundPage />} />
            <Route path="cancellation" element={<CancellationPage />} />
            <Route path="contact" element={<ContactPage />} />
            <Route path="account-deletion" element={<AccountDeletionPage />} />
            <Route path="*" element={<NotFoundPage />} />
          </Route>

          <Route path="app">
            <Route path="oauth/callback" element={<OAuthCallbackPage />} />
            <Route element={<AppGate />}>
              <Route element={<AppShell />}>
                <Route index element={<OverviewPage />} />
                <Route path="groups" element={<GroupsPage />} />
                <Route path="groups/:groupId" element={<GroupDetailPage />} />
                <Route path="friends" element={<FriendsPage />} />
                <Route path="friends/:friendId" element={<FriendDetailPage />} />
                <Route path="account" element={<AccountPage />} />
              </Route>
            </Route>
          </Route>
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  )
}
