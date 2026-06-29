/// Single source of truth for all API endpoint paths.
///
/// The base URL is configured in [dio_client.dart] as `_baseUrl`.
/// Change it there once to redirect the entire app to a different backend.
/// All paths here are relative — Dio prepends the base URL automatically.
abstract final class ApiEndpoints {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const login = '/api/members/login';
  static const forgotPassword = '/api/members/forgot-password';

  // ── News ──────────────────────────────────────────────────────────────────
  static const news = '/api/hotnews';
  static const newsCategories = '/api/hotnews/categories';

  // ── PPP ───────────────────────────────────────────────────────────────────
  static const ppp = '/api/ppp';
  static String pppPolicies(String id) => '/api/ppp/$id/policies';
  static String pppInvestments(String id) => '/api/ppp/$id/investment-opportunities';
  static String pppVideos(String id) => '/api/ppp/$id/getVideo';
  static String pppImages(String id) => '/api/ppp/$id/getImage';
  static String pppPdfs(String id) => '/api/ppp/$id/getPdf';
  static String pppDirectory(String id) => '/api/StackHolder/getStackHolderByPPPId/$id';
  static const pppRegister = '/api/StackHolder/addStackHolder';

  // ── Campus ────────────────────────────────────────────────────────────────
  static const campus = '/api/campus';
  static const advisoryBoard = '/api/advisoryBoard/getAdvisoryBoard';
  static const skillDevelopment = '/api/skillDevelopment';
  static const destinationProgram = '/api/destinationProgram/addDestinationProgram';
  static const addSkillDevelopment = '/api/skillDevelopment/addSkillDevelopment';

  // ── Associations ──────────────────────────────────────────────────────────
  static String circulars(String assId) => '/api/circulars/$assId';
  static String updates(String assId) => '/api/updates/$assId';
  static String memberSearch = '/api/members/search';

  // ── Marketplace ───────────────────────────────────────────────────────────
  static const villaRates = '/api/elivaas/rates';
  static const villaCities = '/api/elivaas/cities';
  static const villaBooking = '/api/elivaas/booking';
  static const paymentVilla = '/api/payment/villa';
  static const tailorMadeDestinations = '/api/tailer-made/destination';
  static const tailorMadeAdd = '/api/tailer-made/add';
  static String tailorMadeByMember(String memberId) => '/api/tailer-made/getByMemberId/$memberId';

  // ── Insurance ─────────────────────────────────────────────────────────────
  static const insurancePlans = '/api/insurence/plans';
  static const insuranceOrder = '/api/payment/insurance-order';
  static const insurancePolicyCreate = '/api/policy/create';

  // ── Visa ──────────────────────────────────────────────────────────────────
  static const visaSubmit = '/api/visa/addVisaToSheet';

  // ── Jobs ──────────────────────────────────────────────────────────────────
  static const jobs = '/api/jobs';

  // ── Video ─────────────────────────────────────────────────────────────────
  static String interviewsByCategory(String category, int page, int size) =>
      '/api/interview/getAllInterviewByCategory/$category/$page/$size';
}
