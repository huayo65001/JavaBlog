## 找到数组中重复的数字

``` /**
 * 找出数组中重复的数字。
 * 在一个长度为 n 的数组 nums 里的所有数字都在 0～n-1 的范围内。
 * 数组中某些数字是重复的，但不知道有几个数字重复了，也不知道每个数字重复了几次。请找出数组中任意一个重复的数字。
 *
 * 所谓原地交换，就是如果发现这个坑里面的萝卜不是这个坑应该有的萝卜，就看看你是哪家的萝卜，然后把你送到哪家，再把你家里现在那个萝卜拿回来。
 * 拿回来之后，再看看拿回来的这个萝卜应该是属于哪家的，再跟哪家交换。
 * 就这样交换萝卜，直到想把这个萝卜送回它家的时候，发现人家家里已经有了这个萝卜了（双胞胎啊），那这个萝卜就多余了，就把这个萝卜上交给国家。
 *
 * @author：hanzhigang
 * @Date : 2021/3/1 11:00 PM
 */
public class OfferDemo03 {

//  找出任意一个重复的数字
    public int findRepeatNumber(int[] nums) {
//      笨办法，两遍for循环，pass
//      尝试使用HashSet的方式，如果Set中存在就返回该值，时间复杂度O(n)，空间复杂度O(n)
//      原地置换的方法，时间复杂度O(n)，空间复杂度O(1)
        for(int i=0;i<nums.length;i++){
            while(nums[i]!=i){
                if(nums[i]==nums[nums[i]]){
                    return nums[i];
                }
                int temp = nums[i];
                nums[i] = nums[temp];
                nums[temp] = temp;
            }
        }
        return 0;
    }
}
```
