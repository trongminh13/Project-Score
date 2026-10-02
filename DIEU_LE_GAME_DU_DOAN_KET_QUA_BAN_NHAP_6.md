# ĐIỀU LỆ GAME DỰ ĐOÁN KẾT QUẢ

### Bản nháp 6 – Phiên bản đề xuất hoàn thiện (cập nhật theo review backend)

**Ngày cập nhật:** 02/10/2026
**Phiên bản trước:** Bản nháp 5
**Trạng thái:** Bản dự thảo để chốt sản phẩm, kỹ thuật và pháp lý
**Mùa áp dụng:** 2026/27

> **Lưu ý:** Đây là bản đặc tả luật sản phẩm và thể lệ game. Trước khi công bố chính thức cho người dùng, các nội dung liên quan đến Plus, thanh toán, giải thưởng, độ tuổi, khuyến mại, thuế và điều kiện nhận giải phải được bộ phận pháp lý xác nhận.

---

# 1. TỔNG QUAN

## 1.1. Mục tiêu

Game **Dự đoán kết quả** cho phép người chơi lựa chọn các trận đấu bóng đá thuộc phạm vi giải đấu được công bố và dự đoán kết quả theo ba khả năng:

* **Chủ** – đội chủ nhà thắng.
* **Hòa** – hai đội hòa.
* **Khách** – đội khách thắng.

Mỗi dự đoán đúng được **10 điểm**.

Người chơi có thể tham gia theo hai gói:

* **Free**
* **Plus**

Hai gói có số lượng slot tối đa và bảng xếp hạng riêng.

---

## 1.2. Nguyên tắc cốt lõi

Game sử dụng các thuật ngữ:

* **Dự đoán**
* **Điểm**
* **Slot**
* **Danh sách dự đoán**
* **Bảng xếp hạng**
* **Tuần dự đoán**

Không sử dụng trong giao diện và điều lệ các thuật ngữ:

* Cược
* Đặt cược
* Kèo
* Tỷ lệ cược
* Tiền cược
* Thắng cược
* Thua cược

Game không cho phép người chơi đặt tiền trực tiếp vào từng trận hoặc dự đoán để nhận tiền theo từng trận.

---

## 1.3. Múi giờ

Tất cả thời gian hiển thị cho người chơi sử dụng:

**Giờ Việt Nam (UTC+7).**

Tuy nhiên:

* thời điểm khóa slot;
* thời điểm mở/đóng tuần;
* thời điểm ghi nhận kết quả;
* thời điểm chấm điểm;
* thời điểm xác định thứ hạng;

được quyết định bởi **thời gian máy chủ** và dữ liệu chính thức từ hệ thống dữ liệu trận đấu.

Giờ hiển thị trên thiết bị của người chơi không được sử dụng làm căn cứ xác định thời điểm khóa.

---

# 2. PHẠM VI GIẢI ĐẤU

## 2.1. Mùa 2026/27

Phiên bản đầu tiên bao gồm các giải vô địch quốc gia:

1. Premier League
2. La Liga
3. Serie A
4. Bundesliga
5. Ligue 1

Chỉ các trận đấu thuộc giải vô địch quốc gia được tính.

Không bao gồm:

* Champions League;
* Europa League;
* Conference League;
* cúp quốc gia;
* siêu cúp;
* giao hữu;
* các trận đấu ngoài phạm vi giải được hệ thống công bố.

---

## 2.2. Số đội và số vòng

| Giải           | Đội | Vòng | Trận/vòng |
| -------------- | --: | ---: | --------: |
| Premier League |  20 |   38 |        10 |
| La Liga        |  20 |   38 |        10 |
| Serie A        |  20 |   38 |        10 |
| Bundesliga     |  18 |   34 |         9 |
| Ligue 1        |  18 |   34 |         9 |

Một vòng đầy đủ của cả năm giải có:

**48 trận.**

Game không sử dụng số vòng của từng giải làm đơn vị thời gian chung vì Bundesliga và Ligue 1 có 34 vòng trong khi ba giải còn lại có 38 vòng.

---

## 2.3. Lịch thi đấu

Lịch thi đấu được lấy từ nhà cung cấp dữ liệu được hệ thống sử dụng.

Lịch có thể thay đổi sau khi công bố do:

* thay đổi lịch truyền hình;
* yêu cầu của giải đấu;
* lý do an ninh;
* thời tiết;
* lịch thi đấu châu Âu;
* trận bị hoãn;
* các nguyên nhân bất khả kháng khác.

Do đó, thời gian bóng lăn được sử dụng để khóa slot là **thời gian mới nhất mà máy chủ đã xác nhận**.

---

# 3. TUẦN DỰ ĐOÁN

## 3.1. Định nghĩa

Một **Tuần dự đoán** kéo dài:

**06:00 sáng Thứ Ba → 05:59:59 sáng Thứ Ba kế tiếp, giờ Việt Nam.**

Một trận thuộc tuần nào được xác định theo **thời điểm bóng lăn hiện có trên máy chủ**.

---

## 3.2. Lý do sử dụng Thứ Ba

Mốc Thứ Ba được sử dụng để gom:

* các trận giữa tuần;
* các trận tối Thứ Hai tại châu Âu nhưng rơi vào rạng sáng Thứ Ba tại Việt Nam;
* các trận cuối tuần;

vào cùng một chu kỳ dự đoán.

---

## 3.3. Mở tuần

Danh sách trận của tuần được mở từ:

**06:00 Thứ Ba.**

Ngay khi tuần mở, hệ thống xác định số trận đủ điều kiện dự kiến của tuần.

---

# 4. KHO TRẬN VÀ BIẾN M

## 4.1. Định nghĩa M

**M** là số trận thuộc phạm vi game có thời điểm bóng lăn nằm trong tuần dự đoán và tại thời điểm **06:00 Thứ Ba**:

* chưa bắt đầu;
* chưa bị hủy;
* chưa được xác định là không thi đấu;
* có lịch thi đấu hợp lệ trên hệ thống.

M được xác định một lần tại thời điểm mở tuần.

---

## 4.2. M không tự giảm quota

Sau 06:00 Thứ Ba, nếu một trận:

* bị hoãn;
* bị hủy;
* bị loại khỏi lịch;

thì **M ban đầu và quota của tuần không tự động giảm**.

Slot đã được cấp cho người chơi vẫn giữ nguyên cho đến khi áp dụng quy tắc xử lý trận hoãn/hủy tại Mục 7.

---

## 4.3. Các trường hợp M

### Trường hợp A — M ≥ 10

* Free: tối đa 6 slot.
* Plus: tối đa 10 slot.

Điểm tối đa nếu chọn đủ slot và đúng toàn bộ:

* Free: **65 điểm**
* Plus: **110 điểm**

---

### Trường hợp B — 6 ≤ M < 10

* Free: tối đa 6 slot.
* Plus: tối đa M slot.

Ví dụ:

|  M | Free | Plus |
| -: | ---: | ---: |
|  6 |    6 |    6 |
|  7 |    6 |    7 |
|  8 |    6 |    8 |
|  9 |    6 |    9 |

Điểm tối đa:

**Free = 60 + 5 = 65 điểm**

**Plus = 10 × M + 10 điểm**

Ví dụ M = 8:

**Plus tối đa = 80 + 10 = 90 điểm.**

---

### Trường hợp C — M < 6

Tuần được xem là:

**Tuần tạm dừng.**

Người chơi:

* không chọn trận;
* không có bảng xếp hạng tuần;
* không được cộng điểm tuần;
* không bị tính là bỏ tuần;
* không bị ảnh hưởng chuỗi huy hiệu.

Ứng dụng hiển thị thời điểm tuần tiếp theo mở.

---

# 5. GÓI FREE VÀ PLUS

## 5.0. Định nghĩa quota cho backend

**InitialQuota**
= quota được cấp lúc mở tuần.

**InvalidatedSlots**
= số slot bị hệ thống loại vì nguyên nhân khách quan (trận hoãn ra ngoài tuần và không thay được, trận hủy và không có trận thay thế, trận gián đoạn quá hạn xử lý...).

**ValidQuota**
= InitialQuota − InvalidatedSlots.

> **Quan trọng:** ValidQuota **không giảm** khi ngườichơi tự bỏ slot hoặc chưa chọn đủ slot.

Ví dụ Free:

* InitialQuota = 6, ngườichơi chỉ chọn 4, không có slot bị loại → ValidQuota = 6 → 4/4 đúng **không** được bonus.
* InitialQuota = 6, chọn 6, 1 trận bị hệ thống loại → ValidQuota = 5 → 5/5 đúng **được** bonus.

---

## 5.1. Free

Free có:

* tối đa 6 slot/tuần;
* 10 điểm cho mỗi dự đoán đúng;
* thưởng +5 điểm khi hoàn thành đủ quota và đúng toàn bộ;
* bảng xếp hạng Free riêng.

Điểm tối đa trong tuần bình thường:

**65 điểm.**

---

## 5.2. Plus

Plus có:

* tối đa 10 slot khi M ≥ 10;
* tối đa M slot khi 6 ≤ M < 10;
* 10 điểm cho mỗi dự đoán đúng;
* thưởng +10 điểm khi hoàn thành đủ quota và đúng toàn bộ;
* bảng xếp hạng Plus riêng.

Điểm tối đa:

**10 × số slot thực tế + thưởng hoàn thành.**

Ví dụ M ≥ 10:

**100 + 10 = 110 điểm.**

---

## 5.3. Không bắt buộc chọn đủ slot

Người chơi có thể chọn ít hơn quota tối đa.

Ví dụ Free có quota 6:

* chọn 3 trận: hợp lệ;
* chọn 5 trận: hợp lệ;
* chọn 6 trận: hợp lệ.

Tuy nhiên, **thưởng hoàn thành chỉ được cấp khi người chơi hoàn thành đủ quota hợp lệ của tuần và tất cả các slot đủ điều kiện đều đúng.**

---

## 5.4. Không cộng điểm giữa Free và Plus

Điểm Free và Plus được ghi nhận độc lập.

Một tài khoản nếu được phép sử dụng cả hai chế độ sẽ có:

* điểm Free;
* bảng Free;
* điểm Plus;
* bảng Plus;

riêng biệt.

Không cộng điểm Free vào Plus và ngược lại.

---

## 5.5. Plus subscription thuộc Account, entitlement áp dụng theo tuần

* Plus subscription thuộc về **Account**.
* Quyền Plus được xác định theo từng **Prediction Week**.
* Nếu tài khoản có Plus entitlement hợp lệ tại thờiiểm mở tuần (06:00 Thứ Ba) → tuần đó được áp dụng quota/quyền lợi Plus.
* Subscription của thiết bị **không phải** nguồn xác định quyền Plus.
* Quyền Plus phải nằm ở **account/backend**, không nằm ở app client.

Các trường hợp cần xử lý:

* **Mua Plus giữa tuần:** không áp dụng hồi tố cho tuần đang mở; áp dụng từ tuần kế tiếp.
* **Plus hết hạn giữa tuần:** tuần đã mở vẫn giữ nguyên quyền Plus đến khi tuần kết thúc; các tuần sau áp dụng quota Free.
* **Đổi thiết bị / đăng nhập cùng account trên thiết bị khác:** quyền Plus không đổi, vì entitlement gắn với account.

---

# 6. SLOT DỰ ĐOÁN

## 6.1. Cấu trúc

Mỗi slot gồm:

1. Một trận đấu.
2. Một lựa chọn:

   * Chủ;
   * Hòa;
   * Khách.

Một trận chỉ được xuất hiện tối đa **một lần trong danh sách dự đoán của cùng một người chơi trong cùng một tuần**.

---

## 6.2. Chọn trận

Người chơi được chọn bất kỳ trận nào thuộc kho trận của tuần và chưa bắt đầu.

Không yêu cầu chọn theo thứ tự thời gian.

Ví dụ:

* Slot 1 có thể là trận thứ Sáu.
* Slot 2 có thể là trận Chủ nhật.
* Slot 3 có thể là trận Thứ Bảy.

---

## 6.3. Đổi trận

Trước khi trận đang nằm trong slot bắt đầu, người chơi có thể:

* đổi trận;
* đổi dự đoán;
* bỏ trận để chọn trận khác.

Trận thay thế phải:

* chưa bắt đầu;
* vẫn thuộc phạm vi tuần;
* chưa được sử dụng ở slot khác.

---

## 6.4. Đổi lựa chọn

Người chơi có thể đổi:

**Chủ ↔ Hòa ↔ Khách**

cho đến trước thời điểm khóa của trận.

---

# 7. KHÓA SLOT

## 7.1. Nguyên tắc

Slot được khóa tại thời điểm bóng lăn chính thức của trận.

Ví dụ:

Trận bắt đầu lúc:

**20:00**

thì slot khóa tại:

**20:00 theo giờ máy chủ.**

Không có khoảng thời gian gia hạn do đồng hồ thiết bị của người chơi chạy sai.

---

## 7.2. Sau khi khóa

Sau khi khóa:

* không đổi trận;
* không đổi dự đoán;
* không xóa slot;
* không thay thế slot.

Ứng dụng hiển thị:

**🔒 Đã khóa**

và hiển thị lựa chọn cuối cùng của người chơi.

---

## 7.3. Tránh tranh chấp giờ đá

Máy chủ là nguồn quyết định duy nhất.

Nếu nhà cung cấp dữ liệu cập nhật giờ đá từ 20:00 thành 21:00 trước thời điểm trận bắt đầu, hệ thống sử dụng **21:00**.

Nếu hệ thống nhận dữ liệu thay đổi quá muộn, log máy chủ phải lưu:

* thời gian nhận dữ liệu;
* giờ bóng lăn trước đó;
* giờ bóng lăn mới;
* thời điểm khóa;
* trạng thái slot.

---

# 8. TRẬN BỊ HOÃN, HỦY HOẶC DỜI

## 8.1. Dời giờ nhưng vẫn trong tuần

Nếu trận bị dời giờ nhưng vẫn thuộc cùng tuần và chưa bắt đầu:

* slot vẫn giữ nguyên;
* dự đoán vẫn giữ nguyên;
* thời điểm khóa được cập nhật theo giờ mới.

Người chơi không bắt buộc phải chọn lại.

---

## 8.2. Hoãn ra ngoài tuần

Nếu trận bị hoãn sang tuần khác:

* slot hiện tại được mở lại;
* dự đoán cũ không được chuyển sang trận mới;
* người chơi được chọn một trận khác chưa bắt đầu;
* ứng dụng gửi thông báo cho người chơi.

---

## 8.3. Trận bị hủy

Nếu trận bị hủy và không có lịch thi đấu lại trong phạm vi tuần:

* slot được đánh dấu **Không hợp lệ**;
* người chơi được chọn trận thay thế nếu vẫn còn trận đủ điều kiện;
* trận bị hủy không được tính là đúng hoặc sai.

---

## 8.4. Không còn trận thay thế

Nếu slot bị mất nhưng tại thời điểm đó không còn trận phù hợp để thay:

* slot được đánh dấu **Không có trận thay thế**;
* slot không được tính điểm;
* slot đó không được tính là dự đoán sai.

Quota hiệu lực của người chơi được điều chỉnh tương ứng.

---

## 8.5. Quy tắc thưởng sau khi slot bị loại

Nếu slot bị loại vì nguyên nhân khách quan từ trận đấu và người chơi không còn khả năng thay thế:

> Điều kiện “đúng hết slot” được tính trên **các slot hợp lệ còn lại**, không tính slot bị loại.

Ví dụ:

* Quota ban đầu: 6.
* Người chơi chọn đủ 6.
* Một trận bị hủy và không có trận thay thế.
* Còn 5 slot hợp lệ.
* Nếu cả 5 đều đúng → người chơi vẫn đạt thưởng hoàn thành.

Quy tắc này phải được hiển thị rõ trong ứng dụng để tránh người chơi hiểu rằng họ bị mất thưởng do sự kiện ngoài kiểm soát.

---

# 9. TRẬN BỊ GIÁN ĐOẠN

Nếu trận:

* bị dừng;
* bị đình chỉ;
* bị tạm hoãn giữa trận;
* không hoàn tất trong ngày;

thì hệ thống **không tự động chấm điểm**.

Chỉ chấm khi giải đấu hoặc nguồn kết quả chính thức công bố kết quả cuối cùng được hệ thống chấp nhận.

---

## 9.1. Hạn xử lý

Nếu sau **7 ngày kể từ giờ bóng lăn ban đầu** vẫn chưa có kết quả chính thức:

* slot được xem xét loại khỏi kỳ dự đoán;
* không tính đúng/sai;
* không tính điểm;
* áp dụng quy tắc slot bị loại.

> Thời hạn 7 ngày hiện vẫn là tham số cần xác nhận.

---

# 10. KẾT QUẢ VÀ CÁCH TÍNH ĐIỂM

## 10.1. Kết quả được sử dụng

Kết quả dùng để chấm là kết quả chính thức của giải đấu sau:

**90 phút + thời gian bù giờ.**

Không tính:

* hiệp phụ;
* luân lưu;

đối với các trận thuộc giải vô địch quốc gia trong phạm vi phiên bản này.

---

## 10.2. Ví dụ

Nếu kết quả là:

**Liverpool 2–0 Arsenal**

Dự đoán:

* Chủ → đúng → +10 điểm.
* Hòa → sai → +0 điểm.
* Khách → sai → +0 điểm.

---

## 10.3. Chấm điểm

Mỗi slot hợp lệ:

* đúng: **+10**
* sai: **+0**

Không có:

* điểm âm;
* điểm cho dự đoán gần đúng;
* điểm phụ theo cách biệt bàn thắng.

---

# 11. THỜI ĐIỂM CHẤM ĐIỂM

Khi một trận có kết quả chính thức:

1. Hệ thống ghi nhận kết quả.
2. Hệ thống xác định dự đoán đúng/sai.
3. Cộng điểm.
4. Cập nhật bảng tuần.
5. Cập nhật các chỉ số liên quan.
6. Cập nhật huy hiệu nếu đủ điều kiện.

---

## 11.1. Trạng thái bảng xếp hạng

Leaderboard nên có hai trạng thái:

### Tạm thời

Hiển thị khi tuần vẫn còn trận chưa có kết quả.

### Chính thức

Chỉ xác nhận sau khi tất cả **slot đã được ngườichơi chọn và còn hợp lệ** đã có kết quả hoặc đã được xử lý theo luật trận bị loại. Ví dụ: tuần có 15 trận, ngườichơi Free chỉ chọn 6 → chỉ cần 6 slot đó được chấm xong là có thể finalize điểm của ngườichơi đó, không cần chờ toàn bộ 15 trận.

Điều này giúp tránh trường hợp thứ hạng thay đổi sau khi người dùng tưởng rằng tuần đã kết thúc.

---

# 12. MÃ DỰ ĐOÁN 1/2/3

Sau khi người chơi hoàn thành danh sách dự đoán, ứng dụng tạo **Mã dự đoán**.

Quy ước:

* **1 = Chủ**
* **2 = Hòa**
* **3 = Khách**

Bắt buộc hiển thị chú thích:

> **1 = Chủ · 2 = Hòa · 3 = Khách**

---

## 12.1. Thứ tự mã

Các chữ số được sắp theo:

**thời gian bóng lăn tăng dần.**

Ví dụ:

1. Trận A – Chủ
2. Trận B – Khách
3. Trận C – Hòa
4. Trận D – Khách
5. Trận E – Chủ
6. Trận F – Hòa

Mã:

**132312**

---

## 12.2. Slot chưa chọn

Nếu tạo mã trước khi hoàn thành danh sách:

**–**

được sử dụng cho slot chưa có dự đoán.

---

## 12.3. Mã không phải căn cứ chấm điểm

Mã chỉ phục vụ:

* xem lại;
* chia sẻ;
* hiển thị trên hồ sơ;
* hiển thị trên thẻ chia sẻ.

Backend vẫn phải lưu dự đoán theo từng trận.

Không dùng chuỗi mã làm dữ liệu chấm điểm chính.

---

# 13. LỊCH SỬ DỰ ĐOÁN

Người chơi có thể xem:

* trận;
* giờ đá;
* dự đoán;
* trạng thái khóa;
* kết quả;
* điểm;
* thời điểm chấm.

Mỗi slot nên có trạng thái:

* Chưa chọn
* Đã chọn
* Đã khóa
* Đúng
* Sai
* Hoãn
* Hủy
* Không hợp lệ
* Đã chấm lại

---

# 14. BẢNG XẾP HẠNG

Mỗi gói có 3 loại bảng:

1. Tuần
2. Tháng
3. Mùa

Free và Plus luôn có bảng riêng.

---

# 15. BẢNG TUẦN

Điểm tuần là tổng điểm của các slot hợp lệ trong tuần cộng thưởng nếu đạt điều kiện.

Tuần thuộc tháng dựa trên:

**ngày bắt đầu tuần – Thứ Ba.**

Ví dụ:

Tuần bắt đầu:

**30/09/2026**

được tính cho tháng:

**09/2026**

dù tuần kết thúc vào tháng 10.

---

# 16. BẢNG THÁNG

Điểm tháng = tổng điểm của các tuần dự đoán thuộc tháng đó.

Tuần tạm dừng:

* không cộng điểm;
* không làm giảm thành tích;
* không được tính là tuần 0 điểm.

---

# 17. BẢNG MÙA

Mùa game:

* bắt đầu từ ngày ra mắt;
* tuần đầu tiên là tuần bắt đầu lúc 06:00 Thứ Ba đầu tiên sau ngày ra mắt;
* không tính điểm cho thời gian trước ngày ra mắt.

Mùa kết thúc sau khi trận cuối cùng thuộc phạm vi mùa có kết quả chính thức.

---

## 17.1. Điểm mùa

Điểm mùa được tính bằng tổng:

**N tuần có điểm cao nhất.**

Trong đó:

**N = 80% số tuần hợp lệ của mùa, làm tròn xuống, tối thiểu 1.**

Ví dụ:

28 tuần hợp lệ:

**N = floor(28 × 80%) = 22.**

Nếu người chơi tham gia ít hơn N tuần:

> cộng tất cả các tuần mà người chơi đã tham gia.

---

## 17.2. Lý do dùng N tuần tốt nhất

Quy tắc này nhằm hạn chế việc người chơi bị bất lợi chỉ vì:

* nghỉ phép;
* không tham gia một số tuần;
* bỏ lỡ một số tuần;

và giảm ảnh hưởng của những tuần có lịch thi đấu đặc biệt.

> Tham số 80% vẫn cần được product/business duyệt.

---

# 18. GHIM HẠNG CỦA NGƯỜI CHƠI

Trong mọi bảng xếp hạng, nếu người chơi không nằm trong vùng đang hiển thị:

**hạng của chính người chơi được ghim ở cuối màn hình.**

Ví dụ:

> #428 — Bạn — 320 điểm

Người chơi vẫn có thể xem:

* hạng;
* điểm;
* số trận đúng;
* khoảng cách tới hạng trên;
* khoảng cách tới hạng dưới.

---

# 19. PHÂN ĐỊNH KHI BẰNG ĐIỂM

Không sử dụng bốc thăm.

## 19.1. Bảng tuần

Thứ tự:

1. Điểm tuần cao hơn.
2. Số trận đúng nhiều hơn.
3. Người đạt tổng điểm đó sớm hơn.

Thời điểm đạt điểm được xác định bằng:

**thời điểm chấm trận cuối cùng tạo ra tổng điểm đó.**

Nếu vẫn bằng:

**đồng hạng.**

---

## 19.2. Bảng tháng

Thứ tự:

1. Điểm tháng cao hơn.
2. Số tuần hạng 1 trong tháng nhiều hơn.
3. Điểm tuần cao nhất cao hơn.
4. Tổng số trận đúng nhiều hơn.
5. Đạt tổng điểm đó sớm hơn.
6. Nếu vẫn bằng → đồng hạng.

---

## 19.3. Bảng mùa

Thứ tự:

1. Điểm mùa cao hơn.
2. Số tuần hạng 1 nhiều hơn.
3. Điểm tuần cao nhất cao hơn.
4. Số lần đúng toàn bộ quota nhiều hơn.
5. Tổng số trận đúng nhiều hơn.
6. Đạt điểm mùa đó sớm hơn.
7. Nếu vẫn bằng → đồng hạng.

---

# 20. ĐỊNH NGHĨA “TUẦN THẮNG”

Một người được tính là **thắng tuần** khi đứng hạng 1 bảng tuần của đúng gói Free hoặc Plus.

Nếu có nhiều người đồng hạng 1:

> tất cả những người đồng hạng 1 đều được tính là có một tuần thắng.

---

# 21. HUY HIỆU

Huy hiệu không có giá trị tiền hoặc hiện vật.

Huy hiệu được hiển thị:

* trên hồ sơ;
* lịch sử thành tích;
* thẻ chia sẻ.

---

## 21.1. Vua tuần

Điều kiện:

**Hạng 1 bảng tuần.**

Chu kỳ:

**Tuần.**

---

## 21.2. Trọn vẹn

Điều kiện:

**Đúng toàn bộ quota hợp lệ của tuần và nhận thưởng hoàn thành.**

Chu kỳ:

**Tuần.**

---

## 21.3. Chuỗi lửa

Điều kiện:

**3 tuần hợp lệ liên tiếp**, trong đó mỗi tuần:

* chọn đủ quota;
* đúng ít nhất 50% số slot hợp lệ.

Tuần tạm dừng:

* không làm đứt chuỗi.

---

## 21.4. Nhà tiên tri tháng

Điều kiện:

**Hạng 1 bảng tháng.**

Chu kỳ:

**Tháng.**

---

## 21.5. Chuyên gia giải

Điều kiện:

* đúng ít nhất 70% số trận đã chọn của một giải trong tháng;
* tối thiểu 10 trận thuộc giải đó.

Tỷ lệ:

**Số trận đúng / số trận đã chọn.**

Chỉ tính các trận đã có kết quả chính thức.

---

# 22. TUẦN TẠM DỪNG VÀ HUY HIỆU

Tuần tạm dừng:

* không có bảng tuần;
* không có điểm;
* không tính là tuần bỏ cuộc;
* không làm đứt Chuỗi lửa;
* không tạo huy hiệu tuần;
* không cộng vào số tuần hợp lệ của mùa.

Ứng dụng hiển thị:

> **Tuần này tạm dừng — tuần tiếp theo mở lúc [thời gian].**

---

# 23. GIẢI THƯỞNG MÙA

Theo cấu hình dự kiến hiện tại, mỗi bảng Free và Plus có một bộ giải thưởng riêng.

Mỗi bảng:

| Hạng | Giải thưởng dự kiến       |
| ---: | ------------------------- |
|    1 | iPhone 18 Pro Max         |
|    2 | Apple Watch               |
|    3 | Chuột + bàn phím máy tính |

Các giải thưởng chỉ được trao sau khi:

1. mùa kết thúc;
2. kết quả được chốt;
3. hoàn tất xác minh người nhận giải;
4. xác định người đủ điều kiện.

---

# 24. XÁC MINH NGƯỜI NHẬN GIẢI

Người nhận giải phải đáp ứng toàn bộ điều kiện được công bố trong thể lệ chính thức.

Dự kiến gồm:

* xác minh danh tính;
* số điện thoại đã xác minh;
* một người chỉ sử dụng một tài khoản;
* đủ độ tuổi;
* không gian lận;
* không sử dụng tài khoản ảo;
* không chơi hộ người khác.

---

# 25. CHỐNG GIAN LẬN

Ban tổ chức có quyền kiểm tra các dấu hiệu bất thường, bao gồm nhưng không giới hạn:

* nhiều tài khoản;
* thông tin định danh trùng;
* số điện thoại trùng;
* thông tin thanh toán bất thường;
* hành vi tự động hóa;
* can thiệp API;
* sửa dữ liệu client;
* giả mạo thời gian;
* thao túng dữ liệu dự đoán;
* sử dụng lỗ hổng để thay đổi dự đoán sau thời điểm khóa.

---

## 25.1. Nguyên tắc dữ liệu

Dữ liệu quyết định kết quả phải nằm ở server.

Client không được quyết định:

* thời gian khóa;
* kết quả trận;
* điểm;
* hạng;
* điều kiện nhận thưởng.

---

# 26. LOG VÀ AUDIT

Đối với mỗi slot, hệ thống nên lưu:

* user_id;
* season_id;
* prediction_week_id;
* fixture_id;
* prediction;
* created_at;
* updated_at;
* locked_at;
* kickoff_at;
* result;
* points;
* scoring_at;
* invalidated_at nếu có;
* invalidation_reason nếu có.

Đối với mỗi lần thay đổi dự đoán, hệ thống nên lưu lịch sử:

* giá trị cũ;
* giá trị mới;
* thời điểm thay đổi;
* server timestamp.

Dữ liệu này phục vụ:

* xử lý khiếu nại;
* điều tra gian lận;
* chấm lại;
* audit;
* hỗ trợ khách hàng.

---

# 27. CHẤM LẠI KẾT QUẢ

Nếu giải đấu hoặc nhà cung cấp dữ liệu chính thức thay đổi kết quả sau khi trận đã được chấm:

1. hệ thống cập nhật kết quả;
2. tính lại điểm;
3. cập nhật leaderboard;
4. cập nhật huy hiệu;
5. nếu thay đổi ảnh hưởng đến thứ hạng mùa/tháng/tuần, hệ thống cập nhật lại thứ hạng;
6. thông báo cho người chơi bị ảnh hưởng.

---

# 28. NGUỒN KẾT QUẢ

Nguồn kết quả chính thức của game phải được xác định trước khi phát hành.

Hệ thống không lấy kết quả từ:

* bài đăng mạng xã hội;
* bình luận;
* nguồn không được xác định;
* dữ liệu người dùng.

Nếu nhiều nguồn dữ liệu mâu thuẫn:

> nguồn dữ liệu chính thức được cấu hình trong hệ thống có quyền quyết định.

---

# 29. THÔNG BÁO

Ứng dụng có thể gửi thông báo cho:

### Trước trận

> Trận [Đội A] – [Đội B] sắp bắt đầu. Dự đoán của bạn sẽ khóa lúc [giờ].

### Khi khóa

> Dự đoán [Đội A] – [Đội B] đã được khóa.

### Khi trận kết thúc

> [Đội A] – [Đội B]: [tỷ số]. Dự đoán của bạn: Đúng/Sai.

### Khi trận bị hoãn

> Trận [Đội A] – [Đội B] đã được hoãn. Slot của bạn đã được mở lại.

### Khi đạt huy hiệu

> Bạn vừa nhận huy hiệu [Tên huy hiệu].

### Khi tuần kết thúc

> Tuần dự đoán đã kết thúc. Bạn đạt [X] điểm và hạng [Y].

---

# 30. MÀN HÌNH CHÍNH CỦA GAME

Màn hình chính nên thể hiện tối thiểu:

### Header

* Tuần hiện tại.
* Thời gian còn lại.
* Gói Free/Plus.

### Điểm

* Điểm hiện tại.
* Điểm tối đa có thể đạt.
* Số trận đúng.

### Danh sách trận

Mỗi trận hiển thị:

* logo hai đội;
* tên đội;
* thời gian;
* giải đấu;
* lựa chọn Chủ/Hòa/Khách;
* trạng thái khóa.

### Tiến độ

Ví dụ:

**4/6 slot**

**3 đúng · 1 sai**

### CTA

**Thêm dự đoán**

---

# 31. MÀN HÌNH XÁC NHẬN

Trước khi trận khóa, người chơi có thể xem:

> **Bạn đang dự đoán**

[Đội A]
vs
[Đội B]

**Chủ / Hòa / Khách**

Thời gian khóa:

**02/10/2026 · 20:00**

Nút:

**Xác nhận dự đoán**

---

# 32. MÀN HÌNH KẾT QUẢ TUẦN

Hiển thị:

* tổng điểm;
* điểm thưởng;
* số trận đúng;
* số trận sai;
* số slot;
* hạng tuần;
* mã dự đoán;
* huy hiệu đạt được.

Ví dụ:

**65 điểm**

**6/6 đúng**

**+5 thưởng hoàn thành**

**Hạng #12**

---

# 33. THẺ CHIA SẺ

Thẻ chia sẻ gồm:

* tên người chơi;
* gói Free/Plus;
* tuần;
* mã dự đoán;
* tên các đội;
* biểu tượng giải;
* điểm;
* huy hiệu.

Không chỉ hiển thị chuỗi số.

Ví dụ:

> **Mã dự đoán: 132312**
> 1 = Chủ · 2 = Hòa · 3 = Khách

Mục tiêu là tránh khiến mã dự đoán bị hiểu nhầm thành một loại mã xổ số.

---

# 34. MÙA GAME 2026/27

Mùa dự kiến:

**2026/27**

Mùa bắt đầu từ tuần đầu tiên mở sau ngày ra mắt chính thức.

Không hồi tố điểm trước ngày ra mắt.

Mùa kết thúc sau khi trận cuối cùng trong phạm vi mùa có kết quả chính thức.

---

# 35. LỊCH NGHỈ QUỐC TẾ

Theo cấu hình lịch hiện tại, các khoảng nghỉ quốc tế dự kiến gồm:

* 21/09 – 06/10/2026;
* 09/11 – 17/11/2026;
* 22/03 – 30/03/2027.

Các tuần có ít hơn 6 trận trong phạm vi game áp dụng quy tắc **Tuần tạm dừng**.

Lịch thực tế phải lấy từ hệ thống dữ liệu tại thời điểm vận hành.

---

# 36. CÚP CHÂU ÂU

Phiên bản đầu tiên không đưa Champions League, Europa League hoặc Conference League vào kho trận.

Không sử dụng các trận cúp để lấp tuần tạm dừng.

Nếu bổ sung trong tương lai, phải có một bộ luật riêng về:

* hiệp phụ;
* luân lưu;
* cách xác định kết quả;
* vòng bảng;
* vòng knock-out;
* trận đá hai lượt;
* trận hoãn;
* trận bị đình chỉ.

---

# 37. NGUYÊN TẮC XỬ LÝ NGOẠI LỆ

Nếu một trường hợp chưa được quy định rõ trong điều lệ:

1. ưu tiên dữ liệu chính thức của giải;
2. ưu tiên thời gian máy chủ;
3. không cho phép client tự quyết định;
4. bảo toàn lịch sử thao tác;
5. không thay đổi dự đoán sau thời điểm khóa;
6. nếu cần chấm lại, phải lưu audit log;
7. nếu ảnh hưởng đến thứ hạng, phải cập nhật toàn bộ bảng liên quan.

---

# 38. KHIẾU NẠI

Người chơi có thể gửi khiếu nại liên quan đến:

* kết quả trận;
* điểm;
* khóa dự đoán;
* trận bị hoãn;
* thứ hạng;
* huy hiệu;
* điều kiện nhận giải.

Khiếu nại phải dựa trên:

* trận cụ thể;
* tuần cụ thể;
* slot cụ thể;
* thông tin tài khoản liên quan.

Hệ thống hỗ trợ cần có khả năng tra cứu audit log.

**Thời hạn gửi khiếu nại:** cần được xác định trước khi phát hành.

---

# 39. ĐIỀU CHỈNH ĐIỀU LỆ

Ban tổ chức có thể cập nhật điều lệ khi có:

* thay đổi lịch giải;
* thay đổi dữ liệu;
* thay đổi yêu cầu kỹ thuật;
* yêu cầu pháp lý;
* thay đổi chính sách cửa hàng ứng dụng;
* lỗi nghiêm trọng ảnh hưởng tính công bằng.

Không được thay đổi hồi tố theo cách làm thay đổi một dự đoán đã khóa, trừ trường hợp cần sửa lỗi hệ thống hoặc chấm lại theo kết quả chính thức.

Các thay đổi quan trọng phải được thông báo cho người chơi.

---

# 40. NGUYÊN TẮC CÔNG BẰNG

Game phải bảo đảm:

* cùng một quy tắc cho cùng một tình huống;
* server là nguồn sự thật;
* không chỉnh dự đoán thủ công cho người chơi;
* không ưu tiên tài khoản Plus trong việc chấm điểm;
* không sử dụng thông tin sau giờ khóa để thay đổi dự đoán;
* mọi thay đổi dữ liệu quan trọng phải có log.

Plus chỉ thay đổi **số lượng slot/quyền lợi đã công bố**, không được làm thay đổi kết quả của cùng một dự đoán.

---

# 41. PHỤ LỤC A — CÁC THAM SỐ ĐÃ CHỐT

| Nội dung                        | Giá trị                     |
| ------------------------------- | --------------------------- |
| Giải đấu                        | 5 giải VĐQG châu Âu         |
| Điểm đúng                       | 10                          |
| Free tối đa                     | 6 slot                      |
| Plus tối đa                     | 10 slot                     |
| Free thưởng hoàn thành          | +5                          |
| Plus thưởng hoàn thành          | +10                         |
| Tuần                            | Thứ Ba 06:00 → Thứ Ba 05:59 |
| M tối thiểu để chơi             | 6                           |
| Tuần tạm dừng                   | M < 6                       |
| Kết quả                         | 90 phút + bù giờ            |
| Hiệp phụ                        | Không tính                  |
| Luân lưu                        | Không tính                  |
| Mùa                             | 2026/27                     |
| N tuần tính mùa                 | 80% tuần hợp lệ             |
| Thời hạn kết quả trận gián đoạn | 7 ngày – đề xuất            |

---

# 42. PHỤ LỤC B — CÔNG THỨC

## 42.1. Điểm cơ bản

```text
BaseScore = CorrectPredictions × 10
```

## 42.1a. Quota hiệu lực

```text
InitialQuota   = quota được cấp lúc mở tuần
InvalidatedSlots = số slot bị hệ thống loại vì nguyên nhân khách quan
ValidQuota     = InitialQuota - InvalidatedSlots
```

> ValidQuota không giảm khi ngườichơi tự bỏ/chưa chọn slot.

---

## 42.2. Free

```text
FreeScore = CorrectPredictions × 10 + CompletionBonus
```

Trong đó:

```text
CompletionBonus = 5
```

nếu:

```text
SelectedValidSlots = ValidQuota
AND
CorrectPredictions = ValidQuota
```

---

## 42.3. Plus

```text
PlusScore = CorrectPredictions × 10 + CompletionBonus
```

Trong đó:

```text
CompletionBonus = 10
```

nếu:

```text
SelectedValidSlots = ValidQuota
AND
CorrectPredictions = ValidQuota
```

---

## 42.4. Quota

```text
if M < 6:
    week = PAUSED

elif M >= 10:
    FreeQuota = 6
    PlusQuota = 10

else:
    FreeQuota = 6
    PlusQuota = M
```

---

## 42.5. Điểm tối đa

```text
MaxScore = ValidQuota × 10 + CompletionBonus
```

**Free:**

```text
ValidQuota = 6 (khi không có slot bị loại)
FreeMax = 6 × 10 + 5 = 65
```

Nếu có slot bị hệ thống loại:

```text
ValidQuota = 6 - InvalidatedSlots
FreeMax = ValidQuota × 10 + 5
```

Ví dụ: 1 slot bị loại → ValidQuota = 5 → FreeMax = 55.

**Plus:**

```text
PlusMax = ValidQuota × 10 + 10
```

Ví dụ:

* M = 6, không slot bị loại → PlusMax = 70
* M = 7, không slot bị loại → PlusMax = 80
* M = 8, không slot bị loại → PlusMax = 90
* M = 9, không slot bị loại → PlusMax = 100
* M ≥ 10, không slot bị loại → PlusMax = 110
* M = 10, 2 slot bị hệ thống loại → ValidQuota = 8 → PlusMax = 8 × 10 + 10 = 90

---

# 43. PHỤ LỤC C — TRẠNG THÁI SLOT CHO BACKEND

Đề xuất state machine:

```text
SELECTED
   │
   ├── kickoff
   ↓
LOCKED
   ↓
SCORING
   ↓
CORRECT / WRONG
```

Nhánh ngoại lệ — hoãn ra ngoài tuần:

```text
SELECTED
   │
   ├── postponed outside week
   ↓
REOPENED
   ↓
SELECTED
```

Nhánh ngoại lệ — hủy / bị loại khỏi lịch:

```text
SELECTED
   │
   ├── cancelled / removed
   ↓
INVALIDATED
```

Nếu còn trận thay thế:

```text
INVALIDATED
   ↓
REPLACEMENT_AVAILABLE
   ↓
SELECTED
```

> **Lưu ý:** `CANCELLED` và `INVALIDATED` là trạng thái của **trận**; trạng thái của **slot** tương ứng là `INVALIDATED` (và `REPLACEMENT_AVAILABLE` khi còn trận thay). Không dùng lẫn trạng thái trận và trạng thái slot.

---

# 44. PHỤ LỤC D — TRẠNG THÁI TUẦN

```text
UPCOMING
    ↓
OPEN
    ↓
ACTIVE
    ↓
SCORING
    ↓
FINAL
```

Ngoại lệ:

```text
UPCOMING
    ↓
PAUSED
```

Nếu M < 6 tại thời điểm mở tuần.

---

# 45. PHỤ LỤC E — TRẠNG THÁI TRẬN

```text
SCHEDULED
↓
LIVE
↓
FINISHED
↓
OFFICIAL_RESULT
```

Ngoại lệ:

```text
SCHEDULED → POSTPONED
SCHEDULED → CANCELLED
LIVE → SUSPENDED
SUSPENDED → OFFICIAL_RESULT
```

---

# 46. PHỤ LỤC F — CHECKLIST TRƯỚC KHI PHÁT HÀNH

## Product

* [ ] Chốt giá Plus.
* [ ] Chốt quyền lợi Plus.
* [ ] Chốt M < 6.
* [ ] Chốt quy tắc slot bị loại.
* [ ] Chốt N = 80%.
* [ ] Chốt thời hạn 7 ngày.
* [ ] Chốt điều kiện huy hiệu.
* [ ] Chốt thời gian khiếu nại.
* [ ] Chốt ngày launch.

## Backend

* [ ] Server timestamp.
* [ ] Fixture locking.
* [ ] Prediction audit log.
* [ ] Result versioning.
* [ ] Rescoring.
* [ ] Leaderboard recalculation.
* [ ] Tie-break.
* [ ] Badge engine.
* [ ] Anti-cheat.
* [ ] Notification engine.

## Mobile

* [ ] Tuần hiện tại.
* [ ] Kho trận.
* [ ] Chọn trận.
* [ ] Chọn Chủ/Hòa/Khách.
* [ ] Countdown.
* [ ] Lock state.
* [ ] Hoãn/hủy.
* [ ] Thay trận.
* [ ] Kết quả.
* [ ] Leaderboard.
* [ ] Hồ sơ.
* [ ] Huy hiệu.
* [ ] Mã dự đoán.
* [ ] Share card.

## Legal / Business

* [ ] Xác định bản chất pháp lý của chương trình.
* [ ] Kiểm tra Plus + giải thưởng.
* [ ] Kiểm tra quy định khuyến mại.
* [ ] Kiểm tra điều kiện tham gia.
* [ ] Kiểm tra độ tuổi.
* [ ] Kiểm tra thuế.
* [ ] Kiểm tra điều kiện trao giải.
* [ ] Kiểm tra App Store.
* [ ] Kiểm tra Google Play.
* [ ] Xác định nguồn dữ liệu bóng đá và license.
* [ ] Xác định quyền sử dụng logo CLB.
* [ ] Xác định quyền sử dụng tên giải.
* [ ] Xác định quyền sử dụng ảnh cầu thủ.

---

# 47. PHỤ LỤC G — CÁC NỘI DUNG CHƯA ĐƯỢC PHÉP TỰ ĐỘNG CHỐT

Các nội dung sau phải có quyết định của Product/Business/Legal trước khi công bố:

1. Giá Plus.
2. Phương thức thanh toán Plus.
3. Plus có được mua bằng App Store/Google Play hay không.
4. Plus có phải là điều kiện để tham gia giải thưởng hay không.
5. Người dùng Free có được nhận giải hay không.
6. Bộ giải thưởng (đã chốt): Free 3 giải, Plus 3 giải, tổng 6 giải/mùa.
7. iPhone 18 Pro Max có thực sự là giải thưởng cuối cùng hay chỉ là phương án dự kiến.
8. Nguồn kinh phí giải thưởng.
9. Bên chịu thuế.
10. Thời hạn xác minh người nhận giải.
11. Thời hạn nhận giải.
12. Xử lý giải không có người nhận.
13. Độ tuổi tối thiểu để chơi.
14. Độ tuổi tối thiểu để nhận giải.
15. Có cho người dưới 18 tuổi sử dụng Free hay không.
16. N = 80%.
17. M < 6.
18. Thời hạn 7 ngày đối với trận chưa có kết quả.
19. Điều kiện từng huy hiệu.
20. Thời hạn khiếu nại.
21. Ngày launch.
22. Nhà cung cấp dữ liệu bóng đá.
23. License logo/tên giải/ảnh.
24. Chính sách bảo vệ dữ liệu cá nhân.
25. Cơ chế xử lý tài khoản bị khóa hoặc vi phạm.

---

# 48. NGUYÊN TẮC CUỐI CÙNG

Game Dự đoán kết quả phải được vận hành theo ba nguyên tắc:

### Minh bạch

Người chơi phải biết:

* mình đang dự đoán gì;
* khi nào dự đoán bị khóa;
* cách tính điểm;
* cách tính thưởng;
* cách xếp hạng;
* cách xử lý trận hoãn/hủy;
* cách xác định người nhận giải.

### Công bằng

Mọi người chơi trong cùng một gói áp dụng cùng một luật.

### Có thể kiểm chứng

Mọi quyết định quan trọng của hệ thống phải có dữ liệu và log để có thể kiểm tra lại.

**Điểm số, kết quả, thứ hạng và trạng thái khóa phải được quyết định bởi server và dữ liệu chính thức, không bởi ứng dụng trên thiết bị người chơi.**

---

**Hết bản nháp 6.**
