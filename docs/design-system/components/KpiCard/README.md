Dashboard göstəricisi: bir rəqəm, vahidi və kontekstdə dəyişməsi.

## Nəyi siz verirsiniz

`label`, `value` (rəqəm və ya artıq formatlanmış mətn), `unit`, `decimals`. Kontekst üçün `delta` (faiz), `hint` (müqayisə bazası) və ya `badge`.

## Qaydalar

- Etiket ölçü vahidini deyil, **nəyi ölçdüyünü** deyir: «Anbar dəyəri», vahid isə ayrıca `unit`.
- `delta` verirsənsə `hint` də ver — nəyə nisbətən olduğu yazılmayan faiz mənasızdır.
- **`delta` yönü avtomatik rənglənir, amma bu həmişə düzgün olmur.** Tullantının azalması yaxşıdır: belə hallarda `deltaTone` ilə yönü əl ilə ver.
- Pul göstəricisi `master.product.view_cost` icazəsinə bağlıdır — icazə yoxdursa kartı ümumiyyətlə render etmə.
- Bir dashboard sətrində 4-dən çox kart yığma; beşincisi lazımdırsa ikinci sətrə keç.
- Rəqəm `figure-lg` stilindədir və mono ailədədir — kartlar yan-yana düzüləndə rəqəmlər eyni bazaya oturur.
