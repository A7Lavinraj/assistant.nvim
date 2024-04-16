#include <bits/stdc++.h>
using namespace std;
typedef long long ll;

#define b(x) (1 << ((x)-1))
#define B 10

int i, j, k, n, m, t, q, p3[66] = {1}, sb, res;

int main() {
  for (i = 1; i <= B; i++)
    p3[i] = p3[i - 1] * 3;
  ios::sync_with_stdio(0);
  cin.tie(0);
  cin >> t;
  while (t--) {
    cin >> n >> m >> q;
    vector<int> f(1050), g;
    res = 0;
    vector<pair<int, int>> v;
    for (i = 1; i <= n; i++) {
      string s;
      cin >> s;
      for (j = 1; j <= m; j++)
        if (s[j - 1] == '#')
          v.push_back({i, j});
    }
    while (q--) {
      int x, y, w;
      cin >> x >> y >> w;
      g = f;
      for (int T = 1; T <= B; T++) {
        sb = -p3[T];
        for (auto [i, j] : v)
          if ((i - x) * (i - x) + (j - y) * (j - y) <= T * T)
            sb += w;
        if (sb <= 0)
          continue;
        for (i = 1; i < b(B + 1); i++)
          if (i & b(T))
            g[i] = max(g[i], f[i ^ b(T)] + sb);
      }
      f = g;
    }
    for (i = 1; i < b(B + 1); i++)
      res = max(res, f[i]);
    cout << res << '\n';
  }
}
